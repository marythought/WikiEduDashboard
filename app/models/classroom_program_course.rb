class ClassroomProgramCourse < Course
  # These methods are available as both class and instance methods
  module ClassroomProgramCourseProperties
    def wiki_edits_enabled?
      true
    end

    def string_prefix
      'courses'
    end
  end

  extend ClassroomProgramCourseProperties
  include ClassroomProgramCourseProperties

  ####################
  # Instance methods #
  ####################
  def wiki_title
    prefix = ENV['course_prefix'] + '/'
    escaped_slug = slug.tr(' ', '_')
    "#{prefix}#{escaped_slug}"
  end
end
