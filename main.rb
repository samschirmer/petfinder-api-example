require 'httparty'
require 'nokogiri'
require 'dotenv/load'
require 'active_support/all'

class Shelter 
	attr_accessor :pf_id, :name, :city, :state, :zip, :country, :phone, :email
	def initialize(s)
		self.pf_id = s['id']
		self.name = s['name']
		self.city = s['city']
		self.state = s['state']
		self.zip = s['zip']
		self.country = s['country']
		self.phone = s['phone']
		self.email = s['email']
	end
	def link
		return "https://#{self.pf_id}.petfinder.com".downcase
	end
end

class Pet
	attr_accessor :pf_id,:shelter_id,:name,:animal,:breeds,:mix,:age,:sex,:size,:options,:description,:last_update,:status,:media,:contact
	def initialize(p)
		self.pf_id = p['id']
		self.shelter_id = p['shelterId']
		self.name = p['name']
		self.animal = p['animal']
		self.breeds = p['breeds']
		self.mix = p['mix']
		self.age = p['age']
		self.sex = p['sex']
		self.size = p['size']
		self.options = p['options']
		self.description = p['description']
		self.last_update = p['lastUpdated']
		self.status = p['status']
		self.media = p['media']
		self.contact = p['contact']
	end
	def link
		return "https://petfinder.com/petdetail/#{self.pf_id}"
	end
end

def api_call(params, noun, verb)
	res = HTTParty.get("http://api.petfinder.com/#{noun}.#{verb}?key=#{ENV['PF_KEY']}&format=xml&#{params.to_query}")
end

def map_xml(node, res)
	xml_res = Nokogiri::XML.parse(res.body)
	collection = []
	xml_res.xpath("//#{node}").each do |x|
		h = {}
		x.children.map { |c| h[c.name] = c.text.strip unless c.text.blank? }
		collection.push(h)
	end
	return collection
end

#params = { name: 'Needy Paws', location: '63109' }
params = {}
print 'Enter shelter name: '
params['name'] = gets.chomp
print "\nEnter shelter zip: "
params['location'] = gets.chomp

# raw HTTParty response is returned
response = api_call(params, 'shelter', 'find')
parsed_xml = map_xml('shelter', response)
shelters = parsed_xml.map { |s| Shelter.new(s) }

shelters.each do |s|
	print "\n#{s.pf_id}: #{s.name} in #{s.zip} | #{s.link}"
end

print "\n\nWhich shelter is yours? (enter id): "
chosen = gets.chomp.upcase

chosen_shelter = shelters.find { |s| s.pf_id == chosen }
response = api_call({id: chosen_shelter.pf_id}, 'shelter', 'getPets')
parsed_xml = map_xml('pet', response)
pets = parsed_xml.map { |p| Pet.new(p) } 

pets.each do |p|
	puts "#{p.name} - #{p.link}"
end



