# evan 2018.05.17
class MathExtend

	# 将一个整数随机分成N份, 平均值上下10的浮动，负数默认为1
	def self.rand_array(num, count)
		ary = []
		while count > 0
			ele = (num / count) + (-10..10).to_a.sample
			ele = 1 if ele <= 0
			ary << ele
			num -= ele
			count -= 1
		end
		ary
	end

end