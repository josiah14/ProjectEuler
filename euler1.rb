# defines the list of integers from 'b' downto 'a'
# InverseZ stands for the set of all integers from 0 to Infinity, mathematically denoted 'Z',
# but inverted, so, really, Infinity downto 0.
# The function allows the user to take a subrange of that set that will be 
# lazy evaluated
def InverseZ(a, b) 
   (a.downto b).lazy
end

# defines the list of integers from 'a' up to 'b'
# Z was chosen because it is the standard mathematical name for the set of all 
# integers from 0 to Infinity
# This function allows the user to take a subrange of that set that will be lazy-
# evaluated
def Z(a, b)
   (a..b).lazy
end

# Algorithm Description:
#     The equation numberOfOccurances(smallestMultiple + largestMultiple)/2 gives the sum of all the multiples for a 
#     given range. so, below, the equation
#         term_counts[i](first_multiples[i] + last_multiples[i])/2 
#      => term_counts[i](last_and_first_multiple_sums[i])/2
#     gives the arbitrary sum of the common multiples of a give number in 'multiples' for the specified range.
#
# Parameters:
#     from:       The smallest number of the range to be evaluated
#     to:         The largest number of the range to be evaluaated
#     *multiples: The array of multiples to find the individual sums of
#
# Return:
#     An array of the individual sums for each multiple passed in for the ronge from 'from' to 'to'
def find_sum_for_each_multiple(from, to, *multiples)
   # delete the multiples that do not have any terms within the range
   multiples.flatten.delete_if { |m| m > to }

   # Since the bottom 2 enumerators are lazy, it is not costly (in terms of memory) to define a separate
   # array for traversing the set backwards and forwards
   my_inverse_range = InverseZ to, from
   my_range = Z from, to
   
   # midpoint is not the midpoint of the set from -> to, but the midpoint of the set 0 -> to.
   # This was chosen because of the mathematical properties of this number: for instance, if the multiple
   # being evaluated falls beyond this midpoint, we know it can't occur again before the last number in the 
   # range being evaluated, so, if this number is > 'from', then the sum of this multiple in the range is itself.
   midpoint = (my_inverse_range.first.to_f/2.to_f).ceil 

   last_multiples = multiples.map do |m| 
      value = 0

      # if the multiple is > than the midpoint and falls in the range, then the last multiple in the set
      # is the multiple itself.
      if m > midpoint && m >= from
         value = m

      # if half the multiple is greater than the (midpoint minus the multiple) in the set 0 -> 'to'
      # then the last multiple is twice the multiple itself, provided twice the multiple falls in the range being 
      # evaluated.
      elsif (m/2).floor > (midpoint - m) && 2*m >= from && 2*m <= to
         value = 2*m

      # Otherwise, use brute force to find the last_multiple in the range
      else
         value = my_inverse_range.find { |i| i % m == 0 }.to_i 
      end
   end
   first_multiples = multiples.map do |m| 
      value = 0

      # The first multiple is the multiple itself if the multiple is > than the midpoint 
      # from 0 -> 'to', or also if the multiple itself is in the range being evaluaged and the difference of
      # the multiple minus the first number in the range is less than the multiple itself.
      if m > midpoint || (m >= from && (m - from) < m)
         value = m

      # Otherwise, use brute force to find the first multiple in the range for the multiple passed in
      else
         value = my_range.find { |i| i % m == 0 }.to_i 
      end
   end

   # if the first term of the range is larger than the multiple, calculate how many terms to subtract from the 
   # beginning of the range.  
   excluded_terms = first_multiples.zip(multiples).map { |ms| ms.reduce(:-)/ms[1] }      

   # Calculate the number of terms each multiple has in the range.
   # Zipping and reducing the 'excluded_terms' takes into account the number of terms that fall before the beginning 
   # of the range.
   term_counts = last_multiples.zip(multiples)
                        .map { |ms| ms.reduce(:/) }
                        .zip(excluded_terms)
                        .map { |xs| xs.reduce(:-) }

   last_and_first_multiple_sums = last_multiples.zip(first_multiples).map { |ms| ms.reduce(:+) }
   return last_and_first_multiple_sums.zip(term_counts).map { |xs| xs.reduce(:*)/2 }
end

# Algorithm Description:
#    This method takes an array of numbers and leaves only the smallest unique multiples.  
#    Another way to say this is this method finds all of the lowest unique multiples in the passed
#    in array and eliminates the rest of the terms.  e.g. [3,5,15,7,35] is reduced to [3,5,7].
def eliminate_common_multiples(*multiples)
   pivot = multiples.first
   rest_of_multiples = multiples[1..-1]
   return [pivot] if rest_of_multiples == [] || rest_of_multiples.nil?
   kept_multiples = []
   result = []
   count = 0

   # This started out as an altered quicksort algorithm.  The end result of this logic 
   # is that each multiple 'm' of the 'pivot' that is greater than the 'pivot' is eliminated
   # be not adding it to 'kept_multiples'.  If the 'pivot' is found to be a multiple of the multiple 'm'
   # then that 'pivot' multiple is eliminated by not adding it to 'kept_multiples', and the algorithm kicks
   # out.  The code after this take_while uses recursion to continue evaluating the rest of the multiples in
   # the case where the pivot is eliminated and the algorithm finishes before reaching the end of the
   # multiples list.
   evaluated_multiples = rest_of_multiples.take_while do |m| 
      count += 1
      is_not_term = pivot%m != 0 
      eq = m == pivot
      if m > pivot
         kept_multiples << m if m%pivot != 0
      else
         kept_multiples << m if pivot != m
         pivot = [] if !is_not_term && !eq
      end
      (is_not_term || eq) && count < rest_of_multiples.length
   end
   
   if pivot == []
      result = eliminate_common_multiples(*(kept_multiples + rest_of_multiples[(evaluated_multiples.length)..-1]))
   else
      if (kept_multiples == [] || kept_multiples.nil?)
         result = [pivot] 
      else
         result = [pivot] + eliminate_common_multiples(*kept_multiples)
      end
   end

   return result.to_a.delete_if { |m| m.nil? }
end

# Algorithm Description:
#    Finds the combined sum of all the multiples passed in for the given range from 'from' to 'to'
#    It is straightforward, find the sum of the terms for each multiple in the range, and then add 
#    those sums together.
def find_sum_of_multiples(from, to, *multiples)
   raise 'Range must be an incrementing range' if from > to
   raise 'Range cannot extend below zero' if from < 0

   multiples = eliminate_common_multiples(*multiples)

   sums_of_each_multiple = find_sum_for_each_multiple(from, to, *multiples)

   multiple_combinations = (2..multiples.length)
                              .map { |n| multiples.combination(n).to_a }.to_a.flatten(1)

   # The below takes into consideration that, when computing the sum for more than 1 multiple, the sums of the 
   # common multiples will have to be accounted for.  For example, if 3, 5, and 7 are the multiples we are
   # finding the combined sum for in the given range, then multiples of 15, 35, and 21 will have been counted
   # twice, but subtracting the sums of those multiples will subtract the sum of common multiple 105 one too many
   # times, so it would need to be added back in.  This gives us the pattern [+,-,+,-,+,...] for the multipliers
   # to determine whether the sum of each common multiple should be added or subtracted from the total.
   common_multiples_multipliers = []
   common_multiples = multiple_combinations.map do |ms|
      common_multiples_multipliers << (ms.length%2 == 0 ? 1: -1)
      ms.reduce(:*) 
   end

   sums_of_common_multiples = find_sum_for_each_multiple(from, to,  *common_multiples)
                                 .zip(common_multiples_multipliers)
                                 .map { |xs| xs.reduce(:*) }

   sums_of_common_multiples = [0] if sums_of_common_multiples == []
       
   return sums_of_each_multiple.reduce(:+) - sums_of_common_multiples.reduce(:+)
end

# This is the main script logic

start_time = Time.now.to_f
sum = find_sum_of_multiples(1, 10000, 7, 248, 35, 3, 5) 
end_time = Time.now.to_f

puts "time " + (end_time - start_time).to_s
puts sum
