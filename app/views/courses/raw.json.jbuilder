json.course do
  json.(@course, :title, :description, :start, :end, :school,
                 :term, :subject, :slug, :url, :listed, :approved, :published)

  json.created_count number_to_human @course.revisions.joins(:article).where(articles: {namespace: 0}).where(new_article: true).count
  json.edited_count number_to_human @course.article_count
  json.edit_count number_to_human @course.revisions.count
  json.student_count @course.user_count
  json.trained_count @course.users.role('student').where(trained: true).count
  json.character_count number_to_human @course.character_sum
  json.view_count number_to_human @course.view_sum

  # json.partial! 'courses/uploads', course: @course
  # json.partial! 'courses/students', course: @course
  # json.partial! 'courses/articles', course: @course
  # json.partial! 'courses/revisions', course: @course
  # json.partial! 'courses/weeks', course: @course
end