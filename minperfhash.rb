# Easy Perfect Minimal Hashing
# By Matthew Bunday
#
# Based on:
# Steve Hanov: http://stevehanov.ca/blog/index.php?id=119
# Edward A. Fox, Lenwood S. Heath, Qi Fan Chen and Amjad M. Daoud, 
# "Practical minimal perfect hash functions for large databases", CACM, 35(1):105-121
# also a good reference:
# Compress, Hash, and Displace algorithm by Djamal Belazzougui,
# Fabiano C. Botelho, and Martin Dietzfelbinger

class MinPerfHash
  FNV_MAGIC_NUM = 0x01000193

  # Calculates a distinct hash function for a given string. Each value of the
  # integer d results in a different hash value.
  def hash(d, s)
    d = FNV_MAGIC_NUM if d == 0
    # Use the FNV algorithm from http://isthe.com/chongo/tech/comp/fnv/ 
    s.each_codepoint do |c|
      d = ((d * FNV_MAGIC_NUM) ^ c) & 0xffffffff
    end

    d
  end

  # Take a Ruby hash and create a minimal perfect hash.
  def initialize(h)
    size = h.size

    buckets = Array.new(size) {[]}
    intermediate = Array.new(size) {0}
    values = Array.new(size) {[nil]}

    # Step 1: Place all of the keys into buckets
    h.keys.each do |key|
      buckets[hash(0, key) % size] << key
    end

    # Step 2: Sort the buckets and process the ones with the most items first.
    buckets.sort_by! {|arr| arr.size}

    buckets.each do |bucket|
      break if bucket.size <= 1

      d, item, slots = 1, 0, []

      # Repeatedly try different values of d until we find a hash function
      # that places all items in the bucket into free slots
      while item < bucket.size
        slot = hash(d, bucket[item]) % size
        if !values[slot].nil? or slots.include? slot
          d += 1
          item, slots = 0, []
        else
          slots << slot
          item += 1
        end
      end

      intermediate[hash(0, bucket[0]) % size] = d

      # Finally store the values from this bucket
      (0...bucket.size).each do |i|
        values[slots[i]] = h[bucket[i]]
      end
    end

    # Only buckets with 1 item remain. Process them more quickly by directly
    # placing them into a free slot. Use a negative value of d to indicate
    # this.
    freelist = []
    (0...size).each do |i|
      freelist << i if values[i].nil?
    end

    #for 
      
  end
end
