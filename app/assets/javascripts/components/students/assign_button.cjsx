# TODO:
# * Article input should be its own component, independent of the assign button.
# * WikiChooser should be its own component.
# * Validation and autocompletion for language

React         = require 'react'
ReactRouter   = require 'react-router'
Router        = ReactRouter.Router
Link          = ReactRouter.Link
Expandable    = require '../high_order/expandable'
Popover       = require '../common/popover'
Lookup        = require '../common/lookup'
ServerActions = require '../../actions/server_actions'
AssignmentActions = require '../../actions/assignment_actions'
AssignmentStore = require '../../stores/assignment_store'
ValidationStore = require '../../stores/validation_store'
InputMixin    = require '../../mixins/input_mixin'
TextInput     = require '../common/text_input'
LanguageStore = require '../../stores/language_store'
ProjectStore  = require '../../stores/project_store'

urlToTitle = (article_url) ->
  article_url = article_url.trim()
  return null unless /^http/.test(article_url)

  url_parts = /([a-z-]+)\.(wiki[a-z]+)\.org\/wiki\/([^#]*)/.exec(article_url)
  return null if url_parts.length < 1
  unescaped_parts =
    language: unescape(url_parts[1])
    project: unescape(url_parts[2])
    title: unescape(url_parts[3]).replace(/_/g, ' ') if url_parts.length > 1
  return unescaped_parts

AssignButton = React.createClass(
  displayname: 'AssignButton'
  getInitialState: ->
    send: false
    language: I18n.currentLocale()
    project: "wikipedia"

  componentWillReceiveProps: (nProps) ->
    if @state.send
      @props.save()
      @setState send: false
  stop: (e) ->
    e.stopPropagation()
  getKey: ->
    tag = if @props.role == 0 then 'assign_' else 'review_'
    tag + @props.student.id

  assign: (e) ->
    e.preventDefault()

    raw_title = @refs.lookup.getValue()
    url_parts = urlToTitle raw_title
    if url_parts
      article_title = url_parts.title
    else
      article_title = raw_title.replace(/_/g, ' ')

    # Check if the assignment exists
    # TODO: also filter by wiki
    if AssignmentStore.getFiltered({
      article_title: article_title,
      user_id: @props.student.id,
      role: @props.role
    }).length != 0
      alert I18n.t("assignments.already_exists")
      return

    # Confirm
    return unless confirm I18n.t('assignments.confirm_addition', {
      title: article_title,
      username: @props.student.wiki_id
    })

    # Send
    if(article_title)
      AssignmentActions.addAssignment @props.course_id, @props.student.id, article_title, @state.language, @state.project, @props.role
      @setState send: (!@props.editable && @props.current_user.id == @props.student.id)
      @refs.lookup.clear()

  unassign: (assignment) ->
    return unless confirm(I18n.t('assignments.confirm_deletion'))
    AssignmentActions.deleteAssignment assignment
    @setState send: (!@props.editable && @props.current_user.id == @props.student.id)

  render: ->
    className = 'button border'
    className += ' dark' if @props.is_open

    if @props.assignments.length > 1 || (@props.assignments.length > 0 && @props.permitted)
      raw_a = @props.assignments[0]
      show_button = <button className={className + ' plus'} onClick={@props.open}>+</button>
    else if @props.permitted
      if @props.current_user.id == @props.student.id
        assign_text = I18n.t("assignments.assign_self")
        review_text = I18n.t("assignments.review_self")
      else if @props.current_user.role > 0 || @props.current_user.admin
        assign_text = I18n.t("assignments.assign_other")
        review_text = I18n.t("assignments.review_other")
      final_text = if @props.role == 0 then assign_text else review_text
      edit_button = (
        <button className={className} onClick={@props.open}>{final_text}</button>
      )
    assignments = @props.assignments.map (ass) =>
      if @props.permitted
        remove_button = <button className='button border plus' onClick={@unassign.bind(@, ass)}>-</button>
      if ass.article_url?
        link = <a href={ass.article_url} target='_blank' className='inline'>{ass.article_title}</a>
      else
        link = <span>{ass.article_title}</span>
      <tr key={ass.id}>
        <td>{link}{remove_button}</td>
      </tr>
    if @props.assignments.length == 0
      assignments = <tr><td>{I18n.t("assignments.none_short")}</td></tr>

    projectOptions = for project in ProjectStore.allProjects()
      <option key={project}>{project}</option>

    wikiChooser = (
      <div className="wiki_chooser active">
        <TextInput
          id='language'
          ref='language'
          value={@state.language}
          value_key='language'
          onChange={@changeLanguage}
          required=true
          editable=true
          label={I18n.t('wiki_chooser.language')}
          placeholder={I18n.t('wiki_chooser.language')}
          validation={LanguageStore.validationRegex()}
        />

        <label htmlFor='project'>
          {I18n.t('wiki_chooser.project')}
        </label>
        <select
          id='project'
          ref='wikiProjectSelect'
          value={@state.project}
          onChange={@changeProject}
        >
          {projectOptions}
        </select>
      </div>
    )

    if @props.permitted
      edit_row = (
        <tr className='edit'>
          <td>
            <form onSubmit={@assign}>
              {wikiChooser}

              <label htmlFor='article_lookup'>
                {I18n.t("articles.title")}
              </label>
              <Lookup model='article'
                id='article_lookup'
                placeholder={I18n.t("articles.title_example")}
                ref='lookup'
                onSubmit={@assign}
                disabled=true
              />
              <button className='button border' type="submit">{I18n.t("assignments.label")}</button>
            </form>
          </td>
        </tr>
      )

    <div className='pop__container' onClick={@stop}>
      {show_button}
      {edit_button}
      <Popover
        is_open={@props.is_open}
        edit_row={edit_row}
        rows={assignments}
      />
    </div>

  # TODO: Check whether an URL was pasted, and if so parse into components
  pasteTitle: ->
    url_parts = urlToTitle @refs.lookup.getValue()
    @setState url_parts if url_parts
    # TODO: Populate the fields and clean up article name.

  changeLanguage: (field, value) ->
    @setState language: value

  changeProject: (event) ->
    @setState project: event.target.value
)

module.exports = Expandable(AssignButton)
