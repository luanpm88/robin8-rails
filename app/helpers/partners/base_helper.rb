# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

module Partners::BaseHelper

  def gender_to_string gender
    logger.info(gender)
    print gender
    if gender == 1
      "M"
    elsif gender == 2
      "F"
    else
      "NONE"
    end
  end
  
  def get_all_parent(obj)
    @has_parent = []
    @has_next = true
    @cur_obj = obj.parent
    
    while @has_next
      @has_parent.push(@cur_obj)
    end
    
    print @has_parent.count
    return "<span style='color: green'>TE</span>".html_safe
  end
  
  def check_parent_exist(cur_obj)
    
    if cur_obj.id === nil
      return cur_obj.parent
    else
      return false
    end
    
  end
end
