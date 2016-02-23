#= Helpers for course views
module CourseHelper
  def find_course_by_slug(slug)
    course = Course.find_by_slug(slug)
    if course.nil?
      fail ActionController::RoutingError.new('Not Found'), 'Course not found'
    end
    return course
  end

  def current?(course)
    course.current?
  end

  def pretty_course_title(course)
    "#{course.school} - #{course.title} (#{course.term})"
  end

  # Customized i18n.t that switches on course type
  def t(message_key, *args, course: nil, **kw)
    if message_key.match /^courses/
      # I18n.t will fall back to the plain key if the more specific message doesn't exist.
      kw[:default] = message_key.to_sym
      # Replace with the specific prefix.
      message_key.gsub! /^courses(?=[.])/ do
        course_type = course.try(:type) || Course.default_course_type
        course_type.new.string_prefix
      end
    end
    I18n.t message_key, *args, **kw
  end
end
