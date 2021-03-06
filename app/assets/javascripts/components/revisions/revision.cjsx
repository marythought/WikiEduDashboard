React = require 'react'

Revision = React.createClass(
  displayName: 'Revision'
  render: ->
    chars = 'Chars Added: ' + @props.revision.characters
    ratingClass = 'rating ' + @props.revision.rating
    ratingMobileClass = ratingClass + ' tablet-only'

    <tr className='revision'>
      <td className='popover-trigger desktop-only-tc'>
        <p className='rating_num hidden'>{@props.revision.rating_num}</p>
        <div className={ratingClass}><p>{@props.revision.pretty_rating || '-'}</p></div>
        <div className='popover dark'>
          <p>{I18n.t('articles.rating_docs.' + (@props.revision.rating || '?'))}</p>
        </div>
      </td>
      <td>
        <div className={ratingMobileClass}><p>{@props.revision.pretty_rating || '-'}</p></div>
        <a onClick={@stop} href={@props.revision.article_url} target='_blank' className='inline'><p className='title'>{@props.revision.title}</p></a>
      </td>
      <td className='desktop-only-tc'>{@props.revision.revisor}</td>
      <td className='desktop-only-tc'>{@props.revision.characters}</td>
      <td className='desktop-only-tc date'>{moment(@props.revision.date).format('YYYY-MM-DD   h:mm A')}</td>
      <td>
        <a className='inline' href={@props.revision.url} target='_blank'>diff</a>
      </td>
    </tr>
)

module.exports = Revision
