class DecoupleWikiIds < ActiveRecord::Migration
  def change
    add_column :articles, :native_id, :integer, index: true
    add_column :revisions, :native_id, :integer, index: true
    add_column :revisions, :page_id, :integer, index: true

    reversible do |dir|
      dir.up do
        execute %(
          UPDATE articles
            SET native_id = id
        )

        execute %(
          UPDATE revisions
            SET native_id = id,
                page_id = article_id
        )
      end
      dir.down do
        execute %(
          UPDATE articles
            SET id = native_id
            WHERE native_id IS NOT NULL
        )

        execute %(
          UPDATE revisions
            SET id = native_id,
            WHERE native_id IS NOT NULL
        )

        execute %(
          UPDATE revisions
            SET article_id = page_id
            WHERE page_id IS NOT NULL
        )
      end
    end
  end
end
