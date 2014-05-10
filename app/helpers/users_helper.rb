module UsersHelper
	def notification_message(noti)
    if noti.noti_type == :NewComment 
      comment = Comment.find(noti.source_id) 
      "#{comment.owner.display_name} 在「#{comment.topic.name}」中發佈了一則新評論「#{comment.display_abstract}」"
    elsif noti.noti_type == :NewSupport 
      comment = Comment.find(noti.source_id) 
      target = Comment.find(noti.destination_id) 
     "#{comment.owner.display_name} 支援了你在「#{comment.topic.name}」上的評論「#{target.display_abstract}」" 
    elsif noti.noti_type == :NewOppose 
      comment = Comment.find(noti.source_id) 
      target = Comment.find(noti.destination_id) 
      "#{comment.owner.display_name} 反駁了你在「#{comment.topic.name}」上的評論「#{target.display_abstract}」" 
    elsif noti.noti_type == :NewLike 
      someone = Proxy.find_by(:id => noti.source_id) 
      target = Comment.find(noti.destination_id) 
      "#{someone.display_name} 覺得你在「#{target.topic.name}」上的評論「#{target.display_abstract}」很讚！" 
    elsif noti.noti_type == :NewDislike 
      someone = Proxy.find_by(:id => noti.source_id) 
      target = Comment.find(noti.destination_id) 
      "#{someone.display_name} 覺得你在「#{target.topic.name}」上的評論「#{target.display_abstract}」很爛！"
    elsif noti.noti_type == :Other
      noti.source_id
    elsif noti.noti_type == :Announcement
      noti.source_id
    end
  end

  def clear_notifications
    @user.notifications.each do |noti|
      case noti.noti_type
      when :NewComment then
        if Comment.find(noti.source_id).nil?
          noti.destroy
          next
        end
      when :NewSupport then
        if Comment.find(noti.source_id).nil?
          noti.destroy
          next
        end
        if Comment.find(noti.destination_id).nil?
          noti.destroy
          next
        end
      when :NewOppose then 
        if Comment.find(noti.source_id).nil?
          noti.destroy
          next
        end
        if Comment.find(noti.destination_id).nil?
          noti.destroy
          next
        end
      when :NewLike then
        if Comment.find(noti.destination_id).nil?
          noti.destroy
          next
        end
      when :NewDislike then
        if Comment.find(noti.destination_id).nil?
          noti.destroy
          next
        end
      end
    end
  end
end
