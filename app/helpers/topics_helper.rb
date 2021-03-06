module TopicsHelper

  def badge_for_status(status)
    "<span class='hidden-xs pull-right status-label label #{status_class(status)}'>#{status_label(status).upcase}</span>"
  end

  def badge_for_private(private)

    if private
      logger.info private
      "<span class='hidden-xs pull-right status-label label label-private'>#{t(:private, default: 'PRIVATE').upcase}</span>"
    else
      ""
    end

  end

  def control_for_status(status)
    "<span class='btn status-label label #{status_class(status)}'>#{status_label(status).upcase} <span class='caret'></span> </span>"
  end

  def control_for_privacy(private)

    case private
    when true
        privacy = t(:private, default: 'PRIVATE')
    when false
        privacy = t(:public, default: 'PUBLIC')
    end

    "<span class='btn privacy-label label label-info'>#{privacy} <span class='caret'></span> </span>"
  end


  def assigned_badge(topic)
    if topic.assigned_user_id.nil?
      "<span class='btn status-label label label-warning'>#{t(:unassigned, default: 'UNASSIGNED')}<span class='caret'></span> </span>"
    else
      "<span class='btn status-label label label-warning'>#{topic.assigned_user.name.upcase} <span class='caret'></span> </span>"
    end
  end

  def status_label(status)
    case status
      when 'new'
        t(:new, default: 'new')
      when 'open'
        t(:open, default: 'open')
      when 'active'
        t(:active, default: 'active')
      when 'assigned'
        t(:mine, default: 'mine')
      when 'closed'
        t(:closed, default: 'resolved')
      when 'pending'
        t(:pending, default: 'pending')
      when 'spam'
        t(:spam, default: 'spam')
      when 'trash'
        t(:trash, default: 'trash')
    end
  end

  def status_class(status)
    case status
      when 'new'
        'label-info'
      when 'open'
        'label-success'
      when 'closed'
        'label-default'
      when 'pending'
        'label-warning'
      when 'spam'
        'label-danger'
      when 'trash'
        'label-danger'
    end
  end


end
