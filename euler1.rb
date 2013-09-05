
# defines the list of integers from 'b' downto 'a'
# InverseZ stands for the set of all integers from 0 to Infinity, mathematically denoted 'Z', but inverted, so really Infinity downto 0.  The function allows the user to take a subrange of that set.
def InverseZ (a, b) 
   (a.downto b).lazy
end

def Z (a, b)
   (a..b).lazy
end

# the equation numberOfOccurances(smallestMultiple + largestMultiple)/2 gives the sum of all the multiples for a given range
# so, below, multipleCounts[i](firstMultiples[i] + lastMultiples[i])/2 => multipleCounts[i](lastAndFirstMultipleSums[i])/2
# gives the arbitrary sum of multiples of a give number in multiples for the specified range.
def find_sum_for_each_multiple(from, to, *multiples)
   multiples.delete_if { |m| m > to }
   myReverseArr = InverseZ to, from
   myArr = Z from, to
   midpoint = (myReverseArr.first.to_f/2.to_f).ceil

   lastMultiples = multiples.map do |m| 
      value = 0
      if m > midpoint && m >= from
         value = m
      elsif (m/2).floor > (midpoint - m) && 2*m >= from && 2*m <= to
         value = 2*m
      else
         value = myReverseArr.find { |i| i % m == 0 }.to_i 
      end
   end
   firstMultiples = multiples.map do |m| 
      value = 0
      if m > midpoint || (m >= from && (m - from) < m)
         value = m
      else
         value = myArr.find { |i| i % m == 0 }.to_i 
      end
   end
   excludedTerms = firstMultiples.zip(multiples).map { |xs| xs.reduce(:-)/xs[1] } # if the first term of the range is larger than the multiple, calculate how many multiples to subtract form the below 
                                                                                  # which calculates the number of counts from 0 -> 'to'.
   multipleCounts = lastMultiples.zip(multiples).map { |ms| ms.reduce(:/) }.zip(excludedTerms).map { |xs| xs.reduce(:-) }
   lastAndFirstMultipleSums = lastMultiples.zip(firstMultiples).map { |ms| ms.reduce(:+) }
   sumsOfEachMultiple = lastAndFirstMultipleSums.zip(multipleCounts).map { |xs| xs.reduce(:*)/2 }
end

def eliminate_common_multiples(*multiples)
   p = multiples.first
   xs = multiples[1..-1]
   return [p] if xs == [] || xs.nil?
   ys = []
   result = []
   count = 0

   zs = xs.take_while do |x| 
      count += 1
      m = p%x != 0 
      eq = x == p
      if x > p
         ys << x if x%p != 0
      else
         ys << x if p != x
         p = [] if !m && !eq
      end
      (m || eq) && count < xs.length
   end
   
   if p == []
      result = eliminate_common_multiples(*(ys + xs[(zs.length)..-1]))
   else
      if (ys == [] || ys.nil?)
         result = [p] 
      else
         result = [p] + eliminate_common_multiples(*ys)
      end
   end

   return result.to_a.delete_if { |x| x.nil? }
end


def find_sum_of_multiples(from, to, *multiples)
   raise 'Range must be an incrementing range' if from > to
   raise 'Range cannot extend below zero' if from < 0

   multiples = eliminate_common_multiples(*multiples)

   sumsOfEachMultiple = find_sum_for_each_multiple(from, to, *multiples)

   multipleCombinations = (2..multiples.length).map { |n| multiples.combination(n).to_a }.to_a.flatten(1)

   commonMultipleMultipliers = []
   commonMultiples = multipleCombinations.map do |ms|
      commonMultipleMultipliers << (ms.length%2 == 0 ? 1: -1)
      ms.reduce(:*) 
   end

   sumsOfCommonMults = find_sum_for_each_multiple(from, to, *commonMultiples).zip(commonMultipleMultipliers).map { |xs| xs.reduce(:*) }

   sumsOfCommonMults = [0] if sumsOfCommonMults == []
       
   totalSum = sumsOfEachMultiple.reduce(:+) - sumsOfCommonMults.reduce(:+)
end

start_time = Time.now.to_f
sum = find_sum_of_multiples(1, 999, 3, 5) 
end_time = Time.now.to_f

puts "time " + (end_time - start_time).to_s
puts sum
