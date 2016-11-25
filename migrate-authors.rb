total = Item.count
parsed = 0
puts 'starting...'
Item.select(:id, :author).find_each do |item|
  parsed += 1
  puts "Parsed #{parsed}/#{total}" if parsed % 1000 == 0
  next unless item.author.present?
  item.author.split(',').map(&:strip).each do |author|
    begin
      hash_id = Author.generate_hash(author)
      item.authors << Author.where(hash_id: hash_id).first_or_initialize do |a|
        a.name = author
      end
    rescue ActiveRecord::RecordNotUnique => e
      puts "Not unique error for #{a.name}"
    end
  end
end
puts 'Done!'
