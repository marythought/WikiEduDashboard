require "#{Rails.root}/lib/replica"
require "#{Rails.root}/lib/importers/revision_score_importer"
require "#{Rails.root}/lib/importers/article_importer"
require "#{Rails.root}/lib/importers/view_importer"
require "#{Rails.root}/lib/wiki_api"

#= Imports articles for a category, along with view data and revision scores
class CategoryImporter
  def initialize(wiki)
    @wiki = wiki
  end

  ################
  # Entry points #
  ################

  # Takes a category name of the form 'Category:Foo' and imports all articles
  # in that category. Optionally, also recursively imports subcategories of
  # the specified depth.
  def import_category(category, depth=0)
    article_ids = article_ids_for_category(category, depth)
    import_articles_with_scores_and_views article_ids
  end

  def show_category(category, opts={})
    depth = opts[:depth] || 0
    min_views = opts[:min_views] || 0
    max_wp10 = opts[:max_wp10] || 100
    article_ids = article_ids_for_category(category, depth)
    import_missing_scores_and_views article_ids
    articles = Article.where(id: article_ids).order(average_views: :desc)
               .where('average_views > ?', min_views)
    articles.select do |article|
      wp10 = article.revisions.last.wp10 || 0
      wp10 < max_wp10
    end
  end

  def report_on_category(category, opts={})
    depth = opts[:depth] || 0
    min_views = opts[:min_views] || 0
    max_wp10 = opts[:max_wp10] || 100
    article_ids = article_ids_for_category(category, depth)
    import_missing_scores_and_views article_ids
    views_and_scores_output(article_ids, min_views, max_wp10)
  end

  ##################
  # Output methods #
  ##################
  def views_and_scores_output(page_ids, min_views, max_wp10)
    output = "title,average_views,completeness,views/completeness\n"
    articles = Article.where(id: article_ids)
               .where('average_views > ?', min_views)
    articles.each do |article|
      title = article.title
      completeness = article.revisions.last.wp10.to_f
      next unless completeness < max_wp10
      average_views = article.average_views
      output += "\"#{title}\"," \
                "#{average_views}," \
                "#{completeness}," \
                "#{average_views / completeness}\n"
    end
    output
  end

  ##################
  # Helper methods #
  ##################
  def import_missing_scores_and_views(page_ids)
    existing_article_ids = Article.where(id: article_ids).pluck(:id)
    import_missing_info existing_article_ids
    missing_article_ids = article_ids - existing_article_ids
    import_articles_with_scores_and_views missing_article_ids
  end

  def import_missing_info(page_ids)
    outdated_views = Article
                     .where(id: article_ids)
                     .where('average_views_updated_at < ?', 1.year.ago)
                     .pluck(:id)
    import_average_views outdated_views
    missing_views = Article.where(id: article_ids, average_views: nil)
    import_average_views missing_views

    existing_revisions = Revision.where(article_id: article_ids)
    missing_revisions = article_ids - existing_revisions.pluck(:article_id)

    # Get the missing revisions and update existing_revisions afterwards
    import_latest_revision missing_revisions unless missing_revisions.empty?

    missing_revision_scores = Revision.where(article_id: article_ids, wp10: nil)
    RevisionScoreImporter.update_revision_scores missing_revision_scores
  end

  def import_articles_with_scores_and_views(page_ids)
    ArticleImporter.new(@wiki).import_articles article_ids
    import_latest_revision article_ids
    import_scores_for_latest_revision article_ids
    import_average_views article_ids
  end

  def page_ids_for_category(category, depth=0)
    cat_query = category_query category
    article_ids = get_category_member_properties(cat_query, 'pageid')
    if depth > 0
      depth -= 1
      subcats = subcategories_of(category)
      subcats.each do |subcat|
        article_ids += article_ids_for_category(subcat, depth)
      end
    end
    article_ids
  end

  def get_category_member_properties(query, property)
    property_values = []
    continue = true
    until continue.nil?
      cat_response = WikiApi.new(@wiki).query query
      page_data = cat_response.data['categorymembers']
      page_data.each do |page|
        property_values << page[property]
      end
      continue = cat_response['continue']
      query['cmcontinue'] = continue['cmcontinue'] if continue
    end
    property_values
  end

  def subcategories_of(category)
    subcat_query = category_query(category, 14) # 14 is the Category namespace
    subcats = get_category_member_properties(subcat_query, 'title')
    subcats
  end

  def category_query(category, namespace=0)
    { list: 'categorymembers',
      cmtitle: category,
      cmlimit: 500,
      cmnamespace: namespace, # mainspace articles by default
      continue: ''
    }
  end

  def revisions_query(page_ids)
    { prop: 'revisions',
      pageids: page_ids,
      rvprop: 'userid|ids|timestamp'
    }
  end

  def import_latest_revision(page_ids)
    latest_revisions = get_revision_data page_ids
    revisions_to_import = []
    page_ids.each do |page_id|
      rev_data = latest_revisions[page_id.to_s]['revisions'][0]
      new_article = (rev_data['parentid'] == 0)
      new_revision = Revision.new(id: rev_data['revid'],
                                  article_id: id,
                                  date: rev_data['timestamp'].to_datetime,
                                  user_id: rev_data['userid'],
                                  new_article: new_article)
      revisions_to_import << new_revision
    end
    Revision.import revisions_to_import
  end

  def get_revision_data(page_ids)
    latest_revisions = {}
    page_ids.each_slice(50) do |fifty_ids|
      rev_query = revisions_query(fifty_ids)
      rev_response = WikiApi.new(@wiki).query rev_query
      latest_revisions.merge! rev_response.data['pages']
    end
    latest_revisions
  end

  def import_scores_for_latest_revision(page_ids)
    revisions_to_update = []
    page_ids.each do |page_id|
      next unless Article.exists?(id)
      revision = Article.find(id).revisions.last
      revisions_to_update << revision if revision.wp10.nil?
    end
    RevisionScoreImporter.update_revision_scores revisions_to_update
  end

  def import_average_views(article_ids)
    articles = Article.where(id: article_ids)
    articles = articles.select do |a|
      a.average_views.nil? || a.average_views_updated_at < 1.month.ago
    end
    ViewImporter.update_average_views articles
  end
end
