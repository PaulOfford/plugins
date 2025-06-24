------------------------------------------------- 
-- BMW PT6 CAN protocol postdissector -- 
------------------------------------------------- 

------------------------------------------------- 
-- License - GNU GPL v3 
--      see http://www.gnu.org/licenses/gpl.html 
------------------------------------------------- 

------------------------History-------------------------- 
-- r1 - pjo - Initial release 
-- 
--------------------------------------------------------- 

-- Execution controls ------------------------------------- 
debug_set = false
go_bang = {} 
-- End of Execution Controls ------------------------------ 

VALS_NULL = {
  [0] = ""
}

VALS_SEATBELT_STATUS = {
  [0x28] = "Seatbelt light off",
  [0x29] = "Seatbelt light on"
}

VALS_PT6_CANID = {
	[0x0A8] = "Torque, Clutch and Brake status",
	[0x0AA] = "Engine RPM and throttle position",
	[0x0C0] = "ABS/brake counter",
	[0x0C4] = "Steering Wheel position (A)",
	[0x0C8] = "Steering Wheel position (B)",
	[0x0CE] = "Individual wheel speeds (4x Pairs)",
	[0x0D7] = "Counter (airbag/seatbelt Related)",
	[0x0E2] = "Passenger door status",
	[0x0E6] = "Rear passenger door status",
	[0x0EA] = "Driver door status",
	[0x0EE] = "Rear driver door status",
	[0x0F2] = "Boot status",
	[0x0FA] = "Electric window controls (driver)",
	[0x0FB] = "Electric window controls (passenger)",
	[0x130] = "Ignition and Key status (Term 15 / R ON?)",
	[0x193] = "Timer & Cruise control status",
	[0x19E] = "ABS/braking force",
	[0x1A6] = "Speed as used by the instrument cluster",
	[0x1B4] = "Speed (mph) Handbrake status",
	[0x1C2] = "PDC (reverse/front) sensor data",
	[0x1D0] = "Engine temp, pressure sensor & handbrake",
	[0x1D6] = "MFL (Steering Wheel) buttons",
	[0x1E1] = "Counter and door status",
	[0x1E3] = "Interior light switch",
	[0x1EE] = "Indicator stalk position",
	[0x1F6] = "Indicator status",
	[0x202] = "Lights (dimmer status)",
	[0x21A] = "Lighting status",
	[0x23A] = "Remote control keyfob actions",
	[0x246] = "Air con, demister status",
	[0x24A] = "Reverse status",
	[0x24B] = "Door status similar (A)",
	[0x252] = "Windscreen Wiper Status",
	[0x264] = "iDrive Controller (rotary control)",
	[0x267] = "iDrive Controller (direction/buttons)",
	[0x26E] = "Ignition status",
	[0x273] = "CCC/CIC status",
	[0x277] = "iDrive controller (reply to 0x273)",
	[0x286] = "Rear view mirror, light sensor",
	[0x2A6] = "Windscreen wiper controls",
	[0x2B4] = "Door locking (via remote control)",
	[0x2B8] = "Reset av fuel/speed",
	[0x2BA] = "Counter (toggle/heartbeat)",
	[0x2CA] = "Outside temperature",
	[0x2D6] = "Air Conditioning status",
	[0x2E6] = "Climate control status (fan and temp speed)",
	[0x2EA] = "Climate control status (passenger)",
	[0x2F8] = "Report time and date",
	[0x2FC] = "Door status (B)",
	[0x328] = "1 Second count from battery removal/reset",
	[0x32E] = "Internal temp, light and solar sensors",
	[0x330] = "Odometer, av fuel and range",
	[0x349] = "Fuel level sensors",
	[0x34F] = "Handbrake status",
	[0x362] = "Average mph & Average mpg",
	[0x366] = "Ext temp & range",
	[0x380] = "VIN number",
	[0x394] = "Hours/distance since last service.",
	[0x39E] = "Set time and date",
	[0x3B0] = "Reverse status",
	[0x3B4] = "Battery voltage & charge status",
	[0x3B6] = "Passenger front window status",
	[0x3B7] = "Driver rear window status",
	[0x3B8] = "Driver front window status",
	[0x3B9] = "Passenger rear window status",
	[0x581] = "Seatbelt status",
	[0x7C3] = "Keyfob (security, comfort and CBS data)"
}

VALS_YES_NO = {
    [0] = "No",
    [1] = "Yes"
}

VALS_0X0a8_CLUTCH = {
	[0x00] = "Released",
	[0x01] = "Depressed",
}

VALS_0X130_BYTE_0 = {
	[0x00] = "Engine off",
	[0x40] = "Engine off - key being inserted",
	[0x41] = "Engine off - key position 1",
	[0x45] = "Engine running",
	[0x55] = "Engine starting",
}

-- can id: 0x581
-- format of entry: byte_3, reserved, reserved, description
seatbelt_status_table= {
	{ 0x28, 0, 0, "Seatbelt light off" },
	{ 0x29, 0, 0, "Seatbelt light on" },
    { 0xff, 0, 0, "end of table" }
}

-- declare the extractors for some Fields to be read 
-- these work like getters 
frame_number_f = Field.new("frame.number") 
pt6_can_id_f = Field.new("can.id") 
pt6_can_len_f = Field.new("can.len") 

-- declare the bmw_pt6 as a protocol 
bmw_pt6 = Proto("bmw_pt6","BMW PT6 Postdissector") 

pt6_seatbelt_status = ProtoField.uint8("bmw_pt6.0x581.seatbelt_status", "Seatbelt status", base.HEX, VALS_SEATBELT_STATUS)
pt6_canid = ProtoField.uint16("bmw_pt6.canid", "PT6 CAN ID decode", base.HEX, VALS_PT6_CANID)

pt6_data_byte_0 = ProtoField.uint8("bmw_pt6.data.byte_0", "Byte 0", base.HEX)
pt6_data_byte_1 = ProtoField.uint8("bmw_pt6.data.byte_1", "Byte 1", base.HEX)
pt6_data_byte_2 = ProtoField.uint8("bmw_pt6.data.byte_2", "Byte 2", base.HEX)
pt6_data_byte_3 = ProtoField.uint8("bmw_pt6.data.byte_3", "Byte 3", base.HEX)
pt6_data_byte_4 = ProtoField.uint8("bmw_pt6.data.byte_4", "Byte 4", base.HEX)
pt6_data_byte_5 = ProtoField.uint8("bmw_pt6.data.byte_5", "Byte 5", base.HEX)
pt6_data_byte_6 = ProtoField.uint8("bmw_pt6.data.byte_6", "Byte 6", base.HEX)
pt6_data_byte_7 = ProtoField.uint8("bmw_pt6.data.byte_7", "Byte 7", base.HEX)

pt6_0x0a8_torque = ProtoField.float("bmw_pt6.0x0a8.torque", "Torque (Nm)")
pt6_0x0a8_torque_int = ProtoField.uint16("bmw_pt6.0x0a8.torque_int", "Torque rounded (Nm)", base.DEC)
pt6_0x0a8_clutch = ProtoField.uint8("bmw_pt6.0x0a8.clutch", "Clutch depressed", base.DEC, VALS_YES_NO, 0x01)  -- Byte 5 - .... ...1
pt6_0x0a8_brake = ProtoField.uint8("bmw_pt6.0x0a8.brake", "Brake pedal depressed", base.DEC, VALS_YES_NO, 0x20)  -- Byte 7 - ..1. ....

pt6_0x0aa_throttle_position = ProtoField.uint16("bmw_pt6.0x0aa.throttle_position", "Throttle position", base.DEC)
pt6_0x0aa_rpm = ProtoField.int16("bmw_pt6.0x0aa.rpm", "Engine RPM", base.DEC)

pt6_0x130_byte_0 = ProtoField.uint8("bmw_pt6.0x130.byte_0", "Byte 0", base.HEX, VALS_0X130_BYTE_0)
pt6_0x130_byte_1 = ProtoField.uint8("bmw_pt6.0x130.byte_1", "Byte 1", base.HEX)

-- create myproto protocol and its fields
-- local f_bitfield = ProtoField.uint8("myproto.bitfield", "Command", base.HEX, {[0]="Normal Packet", [1]="Last Packet"}, 0x40)

bmw_pt6.fields = {
  pt6_seatbelt_status, pt6_canid,
  pt6_data_byte_0, pt6_data_byte_1, pt6_data_byte_2, pt6_data_byte_3,
  pt6_data_byte_4, pt6_data_byte_5, pt6_data_byte_6, pt6_data_byte_7,
  pt6_0x0a8_torque, pt6_0x0a8_torque_int, pt6_0x0a8_clutch, pt6_0x0a8_brake,
  pt6_0x0aa_throttle_position, pt6_0x0aa_rpm,
  pt6_0x130_byte_0, pt6_0x130_byte_1
} 


bmw_pt6_invalid = ProtoExpert.new("bmw_pt6.invalid", "bmw_pt6 Invalid PT6 message", expert.group.SEQUENCE, expert.severity.WARN) 
bmw_pt6.experts = {bmw_pt6_invalid} 

-- register our postdissector
register_postdissector(bmw_pt6)

-- format of entry: can_id, has_decode, decode_table, description, protofield_definition
canid_table = {
	{ 0x02fa, 0, 0, "Send frequency data", 0 },
	{ 0x0481, 1, subcmd_opmode_table, "Select transceive mode", civ_subcmd01 },
	{ 0x0581, 1, subcmd_opmode_table, "Seatbelt status", 0 },
	{ 0xff, 0, 0, "end of table", 0 }
}

-- This function gets called when a new trace file is loaded 
function bmw_pt6.init() 
  if debug_set then print("Entering: bmw_pt6.init()") end 
end 

function canid_0x0a8(buffer, ptr, tree)
  local info_text = ""
  local tvbr
  local byte_in_hex

  ptr = ptr + 1  -- skip the first byte

  tvbr = buffer:range(ptr,2)  -- set up a range
  local torque = (tvbr:le_uint() + .0) / 32  -- extract value
  tree:add(pt6_0x0a8_torque, torque)
  ptr = ptr + 2

  tvbr = buffer:range(ptr,2)  -- set up a range
  local torque_int = (tvbr:le_uint() + .0) / 32  -- extract value
  tree:add(pt6_0x0a8_torque_int, torque_int)
  tree:add(pt6_0x0a8_torque_int, 0)
  ptr = ptr + 2

  -- byte 5 - Clutch pedal status
  tvbr = buffer:range(ptr,1)  -- set up a range
  byte_in_hex = tvbr:uint()  -- extract the byte
  tree:add(pt6_0x0a8_clutch, bit.band(byte_in_hex, 0x01))
  ptr = ptr + 2


  -- byte 7 - Brake pedal status
  tvbr = buffer:range(ptr,1)  -- set up a range
  byte_in_hex = tvbr:uint()  -- extract the byte
  tree:add(pt6_0x0a8_brake, bit.band(byte_in_hex, 0x20))

  info_text = torque_int .. " Nm"

  return info_text
end

function canid_0x0aa(buffer, ptr, tree)
  local info_text = ""
  local tvbr
  local byte_in_hex

  ptr = ptr + 2

  tvbr = buffer:range(ptr,2)  -- set up a range
  local throttle_position = tvbr:le_uint()  -- extract value
  tree:add(pt6_0x0aa_throttle_position, throttle_position)
  ptr = ptr + 2

  tvbr = buffer:range(ptr,2)  -- set up a range
  local rpm = tvbr:le_int() / 4  -- extract value
  tree:add(pt6_0x0aa_rpm, rpm)
  ptr = ptr + 2

  info_text = "Throttle: " .. throttle_position .. ", RPM:" .. rpm

  return info_text
end

function canid_0x0c0(buffer, ptr, tree)
  local info_text = ""
  local tvbr
  local byte_in_hex

  info_text = "ABS / Brake counter"

  return info_text
end

function canid_0x0c4(buffer, ptr, tree)
  local info_text = ""
  local tvbr
  local byte_in_hex

  info_text = "Steering Wheel position"

  return info_text
end

function canid_0x0c8(buffer, ptr, tree)
  local info_text = ""
  local tvbr
  local byte_in_hex

  info_text = "Steering wheel position"

  return info_text
end

function canid_0x0ce(buffer, ptr, tree)
  local info_text = ""
  local tvbr
  local byte_in_hex

  info_text = "Individual wheel Speeds"

  return info_text
end

function canid_0x0d7(buffer, ptr, tree)
  local info_text = ""
  local tvbr
  local byte_in_hex

  info_text = "Airbag/seatbelt counter"

  return info_text
end

function canid_0x0e2(buffer, ptr, tree)
  local info_text = ""
  local tvbr
  local byte_in_hex

  info_text = "Passenger door status"

  return info_text
end

function canid_0x0e6(buffer, ptr, tree)
  local info_text = ""
  local tvbr
  local byte_in_hex

  info_text = "Rear passenger door status"

  return info_text
end

function canid_0x0ea(buffer, ptr, tree)
  local info_text = ""
  local tvbr
  local byte_in_hex

  info_text = "Driver door status"

  return info_text
end

function canid_0x0ee(buffer, ptr, tree)
  local info_text = ""
  local tvbr
  local byte_in_hex

  info_text = "Rear driver door status"

  return info_text
end

function canid_0x0f2(buffer, ptr, tree)
  local info_text = ""
  local tvbr
  local byte_in_hex

  info_text = "Boot (trunk) status"

  return info_text
end

function canid_0x0fa(buffer, ptr, tree)
  local info_text = ""
  local tvbr
  local byte_in_hex

  info_text = "Electric window controls - driver"

  return info_text
end

function canid_0x0fb(buffer, ptr, tree)
  local info_text = ""
  local tvbr
  local byte_in_hex

  info_text = "Electric window controls - passenger"

  return info_text
end

function canid_0x130(buffer, ptr, tree)
  -- Ignition and Key status (Term 15 / R ON?)
  local info_text = ""
  local tvbr
  local byte_in_hex

  -- in case we enter here by mistake we need to make sure
  -- we have enough bytes to consume
  if (ptr + 4) > (buffer:len() - 1) then
    return
  end

  tvbr = buffer:range(ptr,1)  -- set up a range
  byte_in_hex = tvbr:uint()  -- extract the byte
  tree:add(pt6_0x130_byte_0, byte_in_hex)
  ptr = ptr + 1

  info_text = VALS_0X130_BYTE_0[byte_in_hex]

  return info_text
end

function canid_0x19e(buffer, ptr, tree)
  local info_text = ""
  local tvbr
  local byte_in_hex

  info_text = "ABS / braking force"

  return info_text
end

function canid_0x1a0(buffer, ptr, tree)
  local info_text = ""
  local tvbr
  local byte_in_hex

  info_text = "??"

  return info_text
end

function canid_0x1a6(buffer, ptr, tree)
  local info_text = ""
  local tvbr
  local byte_in_hex

  info_text = "Speed, as used by the instrument cluster"

  return info_text
end

function canid_0x1b4(buffer, ptr, tree)
  local info_text = ""
  local tvbr
  local byte_in_hex

  info_text = "Speed [mph] and handbrake status"

  return info_text
end

function canid_0x1b5(buffer, ptr, tree)
  local info_text = ""
  local tvbr
  local byte_in_hex

  info_text = "??"

  return info_text
end

function canid_0x1b6(buffer, ptr, tree)
  local info_text = ""
  local tvbr
  local byte_in_hex

  info_text = "??"

  return info_text
end

function canid_0x1d0(buffer, ptr, tree)
  local info_text = ""
  local tvbr
  local byte_in_hex

  info_text = "Engine temp, pressure sensor & handbrake"

  return info_text
end

function canid_0x1d6(buffer, ptr, tree)
  local info_text = ""
  local tvbr
  local byte_in_hex

  info_text = "MFL (Steering Wheel) Buttons"

  return info_text
end

function canid_0x1ee(buffer, ptr, tree)
  local info_text = ""
  local tvbr
  local byte_in_hex

  info_text = "Indicator stalk position"

  return info_text
end

function canid_0x200(buffer, ptr, tree)
  local info_text = ""
  info_text = "??"

  return info_text
end

function canid_0x202(buffer, ptr, tree)
  local info_text = ""
  info_text = "Lights (dimmer status)"

  return info_text
end

function canid_0x21a(buffer, ptr, tree)
  local info_text = ""
  info_text = "Lighting status"

  return info_text
end

function canid_0x23a(buffer, ptr, tree)
  local info_text = ""
  info_text = "Remote control keyfob actions"

  return info_text
end

function canid_0x242(buffer, ptr, tree)
  local info_text = ""
  info_text = "??"

  return info_text
end

function canid_0x246(buffer, ptr, tree)
  local info_text = ""
  info_text = "Air con, demister status"

  return info_text
end

function canid_0x24b(buffer, ptr, tree)
  local info_text = ""
  info_text = "Door status, similar to 0x2fc"

  return info_text
end

function canid_0x26e(buffer, ptr, tree)
  local info_text = ""
  info_text = "Ignition status"

  return info_text
end

function canid_0x2a0(buffer, ptr, tree)
  local info_text = ""
  info_text = "??"

  return info_text
end

function canid_0x2a6(buffer, ptr, tree)
  local info_text = ""
  info_text = "Windscreen wiper controls"

  return info_text
end

function canid_0x2ba(buffer, ptr, tree)
  local info_text = ""
  info_text = "Counter (toggle / heartbeat)"

  return info_text
end

function canid_0x2c0(buffer, ptr, tree)
  local info_text = ""
  info_text = "??"

  return info_text
end

function canid_0x2ca(buffer, ptr, tree)
  local info_text = ""
  info_text = "Outside temperature"

  return info_text
end

function canid_0x2cf(buffer, ptr, tree)
  local info_text = ""
  info_text = "??"

  return info_text
end

function canid_0x2d0(buffer, ptr, tree)
  local info_text = ""
  info_text = "??"

  return info_text
end

function canid_0x2d2(buffer, ptr, tree)
  local info_text = ""
  info_text = "??"

  return info_text
end

function canid_0x2d5(buffer, ptr, tree)
  local info_text = ""
  info_text = "??"

  return info_text
end

function canid_0x2e6(buffer, ptr, tree)
  local info_text = ""
  info_text = "Climate control status (Fan and Temp speed)"

  return info_text
end

function canid_0x2ea(buffer, ptr, tree)
  local info_text = ""
  info_text = "Climate control status (Passenger)"

  return info_text
end

function canid_0x2f0(buffer, ptr, tree)
  local info_text = ""
  info_text = "??"

  return info_text
end

function canid_0x2f4(buffer, ptr, tree)
  local info_text = ""
  info_text = "??"

  return info_text
end

function canid_0x2f6(buffer, ptr, tree)
  local info_text = ""
  info_text = "??"

  return info_text
end

function canid_0x2f8(buffer, ptr, tree)
  local info_text = ""
  info_text = "Report time and date"

  return info_text
end

function canid_0x2fa(buffer, ptr, tree)
  local info_text = ""
  info_text = "Seat occupancy seat belt contacts"

  return info_text
end

function canid_0x2fc(buffer, ptr, tree)
  local info_text = ""
  info_text = "Door status"

  return info_text
end

function canid_0x31d(buffer, ptr, tree)
  local info_text = ""
  info_text = "??"

  return info_text
end

function canid_0x328(buffer, ptr, tree)
  local info_text = ""
  info_text = "One second count from battery removal / reset"

  return info_text
end

function canid_0x32e(buffer, ptr, tree)
  local info_text = ""
  info_text = "Internal Temp, Light and solar sensors"

  return info_text
end

function canid_0x330(buffer, ptr, tree)
  local info_text = ""
  info_text = "Odometer, av fuel, and range"

  return info_text
end

function canid_0x332(buffer, ptr, tree)
  local info_text = ""
  info_text = "??"

  return info_text
end

function canid_0x349(buffer, ptr, tree)
  local info_text = ""
  info_text = "Fuel level sensor"

  return info_text
end

function canid_0x34f(buffer, ptr, tree)
  local info_text = ""
  info_text = "Handbrake status"

  return info_text
end

function canid_0x35c(buffer, ptr, tree)
  local info_text = ""
  info_text = "??"

  return info_text
end

function canid_0x35e(buffer, ptr, tree)
  local info_text = ""
  info_text = "??"

  return info_text
end

function canid_0x360(buffer, ptr, tree)
  local info_text = ""
  info_text = "??"

  return info_text
end

function canid_0x362(buffer, ptr, tree)
  local info_text = ""
  info_text = "Average mph & average mpg"

  return info_text
end

function canid_0x364(buffer, ptr, tree)
  local info_text = ""
  info_text = "??"

  return info_text
end

function canid_0x366(buffer, ptr, tree)
  local info_text = ""
  info_text = "Ext temp & range"

  return info_text
end

function canid_0x367(buffer, ptr, tree)
  local info_text = ""
  info_text = "??"

  return info_text
end

function canid_0x380(buffer, ptr, tree)
  local info_text = ""
  info_text = "VIN number"

  return info_text
end

function canid_0x381(buffer, ptr, tree)
  local info_text = ""
  info_text = "??"

  return info_text
end

function canid_0x395(buffer, ptr, tree)
  local info_text = ""
  info_text = "??"

  return info_text
end

function canid_0x3b0(buffer, ptr, tree)
  local info_text = ""
  info_text = "Reverse status"

  return info_text
end

function canid_0x3b3(buffer, ptr, tree)
  local info_text = ""
  info_text = "??"

  return info_text
end

function canid_0x3b4(buffer, ptr, tree)
  local info_text = ""
  info_text = "Battery voltage & charge status"

  return info_text
end

function canid_0x3bd(buffer, ptr, tree)
  local info_text = ""
  info_text = "??"

  return info_text
end

function canid_0x3be(buffer, ptr, tree)
  local info_text = ""
  info_text = "??"

  return info_text
end

function canid_0x480(buffer, ptr, tree)
  local info_text = ""
  info_text = "??"

  return info_text
end

function canid_0x481(buffer, ptr, tree)
  local info_text = ""
  info_text = "Network Mgmt"

  return info_text
end

function canid_0x4c0(buffer, ptr, tree)
  local info_text = ""
  info_text = "??"

  return info_text
end

function canid_0x4e0(buffer, ptr, tree)
  local info_text = ""
  info_text = "??"

  return info_text
end

function canid_0x4f8(buffer, ptr, tree)
  local info_text = ""
  info_text = "??"

  return info_text
end

function canid_0x4f2(buffer, ptr, tree)
  local info_text = ""
  info_text = "??"

  return info_text
end

function canid_0x581(buffer, ptr, tree)
  local info_text = ""
  local tvbr
  local byte_in_hex

  -- in case we enter here by mistake we need to make sure
  -- we have enough bytes to consume
  if (ptr + 4) > (buffer:len() - 1) then
    return
  end

  ptr = ptr + 3

  tvbr = buffer:range(ptr,1)  -- set up a range
  byte_in_hex = tvbr:uint()  -- extract the byte

  tree:add(pt6_seatbelt_status, byte_in_hex)
  ptr = ptr + 1



  if byte_in_hex == 0x28 then
	info_text = "Seatbelt Status: Warning off"
  end

  if byte_in_hex == 0x29 then
	info_text = "Seatbelt Status: Warning on"
  end

  return info_text
end

function canid_0x592(buffer, ptr, tree)
  local info_text = ""
  info_text = "??"

  return info_text
end

function canid_0x5a9(buffer, ptr, tree)
  local info_text = ""
  info_text = "??"

  return info_text
end

function canid_0x5c0(buffer, ptr, tree)
  local info_text = ""
  info_text = "??"

  return info_text
end

function canid_0x5e0(buffer, ptr, tree)
  local info_text = ""
  info_text = "??"

  return info_text
end

function canid_0x7c3(buffer, ptr, tree)
  local info_text = ""
  info_text = "??"

  return info_text
end

function bmw_pt6.dissector(buffer,pinfo,tree) 

  local info_text 
  local ptr = 0
  local tvbr
  local info_text = "Unknown CAN ID"
  local i -- cmd_table index
  local j -- subcmd_table index

  local length = buffer:len()
  if length == 0 then return end

  can_length = pt6_can_len_f().value
  can_id = pt6_can_id_f().value

  if pinfo.visited then 

    if can_length > 0 then 
      if debug_set then print("Processing PT6 message") end
      pinfo.cols.protocol = bmw_pt6.name

      vals = {}

      local subtree = tree:add(bmw_pt6, buffer(), "BMW PT6 Protocol")
      local rawdatatree = subtree:add(bmw_pt6, buffer(), "BMW PT6 Raw Data")

      ptr = 24

      tvbr = buffer:range(ptr,1)  -- set up a range
      byte_in_hex = tvbr:uint()  -- extract the byte
      rawdatatree:add(pt6_data_byte_0, byte_in_hex)
      ptr = ptr + 1

      tvbr = buffer:range(ptr,1)  -- set up a range
      byte_in_hex = tvbr:uint()  -- extract the byte
      rawdatatree:add(pt6_data_byte_1, byte_in_hex)
      ptr = ptr + 1

      tvbr = buffer:range(ptr,1)  -- set up a range
      byte_in_hex = tvbr:uint()  -- extract the byte
      rawdatatree:add(pt6_data_byte_2, byte_in_hex)
      ptr = ptr + 1

      tvbr = buffer:range(ptr,1)  -- set up a range
      byte_in_hex = tvbr:uint()  -- extract the byte
      rawdatatree:add(pt6_data_byte_3, byte_in_hex)
      ptr = ptr + 1
	  
      tvbr = buffer:range(ptr,1)  -- set up a range
      byte_in_hex = tvbr:uint()  -- extract the byte
      rawdatatree:add(pt6_data_byte_4, byte_in_hex)
      ptr = ptr + 1

      tvbr = buffer:range(ptr,1)  -- set up a range
      byte_in_hex = tvbr:uint()  -- extract the byte
      rawdatatree:add(pt6_data_byte_5, byte_in_hex)
      ptr = ptr + 1

      tvbr = buffer:range(ptr,1)  -- set up a range
      byte_in_hex = tvbr:uint()  -- extract the byte
      rawdatatree:add(pt6_data_byte_6, byte_in_hex)
      ptr = ptr + 1

      tvbr = buffer:range(ptr,1)  -- set up a range
      byte_in_hex = tvbr:uint()  -- extract the byte
      rawdatatree:add(pt6_data_byte_7, byte_in_hex)
      ptr = ptr + 1
	  
	  ptr = ptr - 8

	  subtree:add(pt6_canid, can_id)
	  
	  if can_id == 0x0a8 then info_text = canid_0x0a8(buffer, ptr, subtree) end
	  if can_id == 0x0aa then info_text = canid_0x0aa(buffer, ptr, subtree) end

	  if can_id == 0x0c0 then info_text = canid_0x0c0(buffer, ptr, subtree) end
	  if can_id == 0x0c4 then info_text = canid_0x0c4(buffer, ptr, subtree) end
	  if can_id == 0x0c8 then info_text = canid_0x0c8(buffer, ptr, subtree) end
	  if can_id == 0x0ce then info_text = canid_0x0ce(buffer, ptr, subtree) end

	  if can_id == 0x0d7 then info_text = canid_0x0d7(buffer, ptr, subtree) end

	  if can_id == 0x0e2 then info_text = canid_0x0e2(buffer, ptr, subtree) end
	  if can_id == 0x0e6 then info_text = canid_0x0e6(buffer, ptr, subtree) end
	  if can_id == 0x0ea then info_text = canid_0x0ea(buffer, ptr, subtree) end
	  if can_id == 0x0ee then info_text = canid_0x0ee(buffer, ptr, subtree) end

	  if can_id == 0x0f2 then info_text = canid_0x0f2(buffer, ptr, subtree) end
	  if can_id == 0x0fa then info_text = canid_0x0fa(buffer, ptr, subtree) end
	  if can_id == 0x0fb then info_text = canid_0x0fb(buffer, ptr, subtree) end

	  if can_id == 0x130 then info_text = canid_0x130(buffer, ptr, subtree) end
	  if can_id == 0x19e then info_text = canid_0x19e(buffer, ptr, subtree) end
	  
	  if can_id == 0x1a0 then info_text = canid_0x1a0(buffer, ptr, subtree) end
	  if can_id == 0x1a6 then info_text = canid_0x1a6(buffer, ptr, subtree) end
	  
	  if can_id == 0x1b4 then info_text = canid_0x1b4(buffer, ptr, subtree) end
	  if can_id == 0x1b5 then info_text = canid_0x1b5(buffer, ptr, subtree) end
	  if can_id == 0x1b6 then info_text = canid_0x1b6(buffer, ptr, subtree) end
	  
	  if can_id == 0x1d0 then info_text = canid_0x1d0(buffer, ptr, subtree) end
	  if can_id == 0x1d6 then info_text = canid_0x1d6(buffer, ptr, subtree) end
	  
	  if can_id == 0x1ee then info_text = canid_0x1ee(buffer, ptr, subtree) end

	  if can_id == 0x200 then info_text = canid_0x200(buffer, ptr, subtree) end
	  if can_id == 0x202 then info_text = canid_0x202(buffer, ptr, subtree) end
	  if can_id == 0x21a then info_text = canid_0x21a(buffer, ptr, subtree) end
	  if can_id == 0x23a then info_text = canid_0x23a(buffer, ptr, subtree) end
	  if can_id == 0x242 then info_text = canid_0x242(buffer, ptr, subtree) end
	  if can_id == 0x246 then info_text = canid_0x246(buffer, ptr, subtree) end
	  if can_id == 0x24b then info_text = canid_0x24b(buffer, ptr, subtree) end
	  if can_id == 0x26e then info_text = canid_0x26e(buffer, ptr, subtree) end

	  if can_id == 0x2a0 then info_text = canid_0x2a0(buffer, ptr, subtree) end
	  if can_id == 0x2a6 then info_text = canid_0x2a0(buffer, ptr, subtree) end

	  if can_id == 0x2ba then info_text = canid_0x2ba(buffer, ptr, subtree) end

	  if can_id == 0x2c0 then info_text = canid_0x2c0(buffer, ptr, subtree) end
	  if can_id == 0x2ca then info_text = canid_0x2ca(buffer, ptr, subtree) end
	  if can_id == 0x2cf then info_text = canid_0x2cf(buffer, ptr, subtree) end
	  
	  if can_id == 0x2d0 then info_text = canid_0x2d0(buffer, ptr, subtree) end
	  if can_id == 0x2d2 then info_text = canid_0x2d2(buffer, ptr, subtree) end
	  if can_id == 0x2d5 then info_text = canid_0x2d5(buffer, ptr, subtree) end

	  if can_id == 0x2e6 then info_text = canid_0x2e6(buffer, ptr, subtree) end
	  if can_id == 0x2ea then info_text = canid_0x2ea(buffer, ptr, subtree) end

	  if can_id == 0x2f0 then info_text = canid_0x2f0(buffer, ptr, subtree) end
	  if can_id == 0x2f4 then info_text = canid_0x2f4(buffer, ptr, subtree) end
	  if can_id == 0x2f6 then info_text = canid_0x2f6(buffer, ptr, subtree) end
	  if can_id == 0x2f8 then info_text = canid_0x2f8(buffer, ptr, subtree) end
	  if can_id == 0x2fa then info_text = canid_0x2fa(buffer, ptr, subtree) end
	  if can_id == 0x2fc then info_text = canid_0x2fc(buffer, ptr, subtree) end
	  
	  if can_id == 0x31d then info_text = canid_0x31d(buffer, ptr, subtree) end
	  if can_id == 0x328 then info_text = canid_0x328(buffer, ptr, subtree) end
	  if can_id == 0x32e then info_text = canid_0x32e(buffer, ptr, subtree) end
	  if can_id == 0x330 then info_text = canid_0x330(buffer, ptr, subtree) end
	  if can_id == 0x332 then info_text = canid_0x332(buffer, ptr, subtree) end
	  
	  if can_id == 0x349 then info_text = canid_0x349(buffer, ptr, subtree) end
	  if can_id == 0x34f then info_text = canid_0x34f(buffer, ptr, subtree) end
	  
	  if can_id == 0x35c then info_text = canid_0x35c(buffer, ptr, subtree) end
	  if can_id == 0x35e then info_text = canid_0x35e(buffer, ptr, subtree) end
	  
	  if can_id == 0x360 then info_text = canid_0x360(buffer, ptr, subtree) end
	  if can_id == 0x362 then info_text = canid_0x362(buffer, ptr, subtree) end
	  if can_id == 0x364 then info_text = canid_0x364(buffer, ptr, subtree) end
	  if can_id == 0x366 then info_text = canid_0x366(buffer, ptr, subtree) end
	  if can_id == 0x367 then info_text = canid_0x367(buffer, ptr, subtree) end
	  
	  if can_id == 0x380 then info_text = canid_0x380(buffer, ptr, subtree) end
	  if can_id == 0x381 then info_text = canid_0x381(buffer, ptr, subtree) end
	  if can_id == 0x395 then info_text = canid_0x395(buffer, ptr, subtree) end

	  if can_id == 0x3b0 then info_text = canid_0x3b0(buffer, ptr, subtree) end
	  if can_id == 0x3b3 then info_text = canid_0x3b3(buffer, ptr, subtree) end
	  if can_id == 0x3b4 then info_text = canid_0x3b4(buffer, ptr, subtree) end
	  if can_id == 0x3bd then info_text = canid_0x3bd(buffer, ptr, subtree) end
	  if can_id == 0x3be then info_text = canid_0x3be(buffer, ptr, subtree) end
	  
	  if can_id == 0x480 then info_text = canid_0x480(buffer, ptr, subtree) end
	  if can_id == 0x481 then info_text = canid_0x481(buffer, ptr, subtree) end
	  if can_id == 0x4c0 then info_text = canid_0x4c0(buffer, ptr, subtree) end
	  if can_id == 0x4e0 then info_text = canid_0x4e0(buffer, ptr, subtree) end
	  if can_id == 0x4f2 then info_text = canid_0x4f2(buffer, ptr, subtree) end
	  if can_id == 0x4f8 then info_text = canid_0x4f8(buffer, ptr, subtree) end
	  
	  if can_id == 0x581 then info_text = canid_0x581(buffer, ptr, subtree) end
	  if can_id == 0x592 then info_text = canid_0x581(buffer, ptr, subtree) end
	  if can_id == 0x5a9 then info_text = canid_0x5a9(buffer, ptr, subtree) end
	  if can_id == 0x5c0 then info_text = canid_0x5c0(buffer, ptr, subtree) end
	  if can_id == 0x5e0 then info_text = canid_0x5e0(buffer, ptr, subtree) end
	  if can_id == 0x5f8 then info_text = canid_0x5f8(buffer, ptr, subtree) end

	  if can_id == 0x7c3 then info_text = canid_0x7c3(buffer, ptr, subtree) end

	  pinfo.cols.info:set(info_text) 
      pinfo.cols.info:fence() 

    end 

    if debug_set then print("SNAP03") end 
  end 
end 

