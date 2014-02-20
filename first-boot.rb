#!/usr/bin/env ruby

require 'json'
require 'pp'

$username="audit@pve"
$password="eghooS8v"
$host="74.118.153.242"
$proto="https"
$port="8006"

found = false

def get_path(path)
	json = `curl -k -b "PVEAuthCookie=#{$ticket}" #{$proto}://#{$host}:#{$port}/api2/json/#{path} 2>/dev/null`
	JSON.parse(json)
end

ticket_json = `curl -k -d "username=#{$username}&password=#{$password}" #{$proto}://#{$host}:#{$port}/api2/json/access/ticket 2>/dev/null`
ticket_obj = JSON.parse(ticket_json)
#pp ticket_obj

local_macaddress = `ifconfig | grep HWaddr`.upcase.match(/(?<macaddress>[A-F0-9]{2}:[A-F0-9]{2}:[A-F0-9]{2}:[A-F0-9]{2}:[A-F0-9]{2}:[A-F0-9]{2})/)['macaddress']
# puts local_macaddress

# local_macaddress = "EE:BF:66:3B:37:09"

$ticket = ticket_obj['data']['ticket']
CSRF_Token = ticket_obj['data']['CSRFPreventionToken']

servers = get_path("/nodes")['data'].map {|v| v['node']}
servers.each do |server|
	nodes = get_path("/nodes/#{server}/qemu")
	nodes['data'].each do |node| 
	 	# pp node['name']
	 	vms = get_path("/nodes/#{server}/qemu/#{node['vmid']}/config")
	 	macaddress = vms['data']['net0'].match(/(?<macaddress>[A-F0-9]{2}:[A-F0-9]{2}:[A-F0-9]{2}:[A-F0-9]{2}:[A-F0-9]{2}:[A-F0-9]{2})/)['macaddress']
	 	hostname = vms['data']['name']
	 	if (macaddress == local_macaddress) 
	 		puts hostname
	 		found = true
	 	end
	end
end

if found == false then
	puts "localhost"
end