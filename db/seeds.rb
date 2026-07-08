# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

products = [
  {
    title: "Maple Classic Drumsticks 5A",
    description: "Lightweight maple drumsticks with an oval tip, perfect for jazz and low-volume gigs. Balanced feel and a warm cymbal response.",
    price: 12
  },
  {
    title: "Hickory Power 5B Drumsticks",
    description: "Durable hickory sticks with a slightly thicker grip for rock and heavy-hitting drummers. Built to survive rimshots night after night.",
    price: 14
  },
  {
    title: "20\" Ride Cymbal — Bright Series",
    description: "A shimmering B20 bronze ride cymbal with clear stick definition and a controlled wash. Great for everything from fusion to pop.",
    price: 249
  },
  {
    title: "16\" Crash Cymbal — Dark Vintage",
    description: "Hand-hammered crash with a dark, trashy character and a fast decay. Adds explosive accents without overpowering the mix.",
    price: 189
  },
  {
    title: "14\" Hi-Hat Pair — Studio Edition",
    description: "Crisp, articulate hi-hats with a tight chick sound. Recording-friendly pair that stays consistent at any dynamic level.",
    price: 279
  },
  {
    title: "22\" Bass Drum — Birch Shell",
    description: "Punchy 22x18 birch bass drum with a focused low end. Includes claw hooks, tension rods, and a pre-muffled batter head.",
    price: 549
  },
  {
    title: "14\" Snare Drum — Steel Shell",
    description: "Bright and cutting steel snare with a wide tuning range. Ten lugs, die-cast hoops, and a sensitive 20-strand snare wire set.",
    price: 199
  },
  {
    title: "Double Bass Drum Pedal — Pro Chain Drive",
    description: "Smooth double-chain drive pedal with adjustable beater angle, spring tension, and footboard height. Fast, quiet, and stable.",
    price: 329
  },
  {
    title: "Drum Throne — Ergonomic Saddle",
    description: "Height-adjustable throne with a contoured memory-foam saddle seat and double-braced tripod legs. Comfortable for long sessions.",
    price: 89
  },
  {
    title: "Practice Pad 12\" — Dual Surface",
    description: "Twelve-inch practice pad with a soft gum rubber side for realistic rebound and a harder side for workout-style conditioning.",
    price: 25
  }
]

products.each do |attrs|
  Product.find_or_create_by!(title: attrs[:title]) do |product|
    product.description = attrs[:description]
    product.price = attrs[:price]
  end
end

puts "Seeded #{Product.count} products."
