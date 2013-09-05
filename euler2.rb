def computeFibNum(x,y)
   (2*((y**4)*x)) + ((y**3)*(x**2)) - (2*((y**2)*(x**3))) - (y**5) - (y*(x**4)) + (2*y)
end

#puts computeFibNum(0,0)# 0
#puts computeFibNum(0,1)# 1
#puts computeFibNum(1,1)# 1
#puts computeFibNum(1,2)# 2
#puts computeFibNum(2,3)# 3
#puts computeFibNum(3,5)# 5
#puts computeFibNum(5,8)
#puts computeFibNum(8,13)

efibs_head = [0,2].lazy

efibs = Enumerator.new do |f|
   f.yield 0
   f.yield 2
   while true
      f.yield efibs.zip(efibs
   end
efibs_basic = efibs_head
efibs_basic = efibs_head + efibs_basic.zip(efibs_basic[1..-1]).map { |a| a[0] + a[1]*4 }
efibs.take(10)  


