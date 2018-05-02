# evan 2018.04.47 get time range
class DateTimeExtend

	def self.sequence(start, stop, step)
	  dates = [start]
	  while dates.last < (stop - step)
	    dates << (dates.last + step)
	  end 
	  return dates
	end

end
# DateTimeExtend.sequence(7.days.ago, 8.days.since, 1.day)