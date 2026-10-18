module ApplicationHelper
  def show_errors(object, field_name)
    if object.errors.any?
      if !object.errors.messages[field_name].blank?
        object.errors.messages[field_name].join(", ")
      end
    end
  end

  def display_gender(user)
    case user&.gender&.to_sym
    when :male
      t("views.user.gender.male")
    when :female
      t("views.user.gender.female")
    when :not_applicable
      t("views.user.gender.not_applicable")
    else
      ''
    end
  end

  def check_permission_admin
    raise ActiveRecord::RecordNotFound unless current_user&.admin?
  end

  def check_current_user_or_representative(user)
    current_user.id == user.id || user.is_representative?
  end

  def check_admin
    current_user&.admin?
  end
end
