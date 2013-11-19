# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

jd = Site::Jd.create(name: "京东商城")
jd.product_roots.create(url: "http://list.jd.com/737-794-798-0-0-0-0-0-0-0-1-1-1-1-1-72-4137-33.html")