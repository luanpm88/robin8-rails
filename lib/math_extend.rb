# evan 2018.05.17
class MathExtend

	# 将一个整数(num)随机分成(count)份正整数
	def self.rand_array(num, count)
		ary, total = [], num - count
		while count > 0
			ele = 1
			if total > 0
				ele += count == 1 ? total : rand(total/count).round
			end
			ary << ele
			total = total - ele + 1
			count -= 1
		end
		ary
	end

end