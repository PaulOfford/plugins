------------------------------------------------- 
-- ISO 15765 OBD II protocol postdissector -- 
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


-- declare the extractors for some Fields to be read 
-- these work like getters 
frame_number_f = Field.new("frame.number") 
docan_can_id_f = Field.new("can.id") 
docan_can_len_f = Field.new("can.len") 

-- declare the docan as a protocol 
docan = Proto("docan","DoCAN Postdissector") 

docan_seatbelt_status = ProtoField.uint8("docan.0x581.seatbelt_status", "Seatbelt status", base.HEX, VALS_SEATBELT_STATUS)
docan_canid = ProtoField.uint16("docan.canid", "DoCAN decode", base.HEX, VALS_docan_CANID)

docan_data_byte_0 = ProtoField.uint8("docan.data.byte_0", "Byte 0", base.HEX)
docan_data_byte_1 = ProtoField.uint8("docan.data.byte_1", "Byte 1", base.HEX)
docan_data_byte_2 = ProtoField.uint8("docan.data.byte_2", "Byte 2", base.HEX)
docan_data_byte_3 = ProtoField.uint8("docan.data.byte_3", "Byte 3", base.HEX)
docan_data_byte_4 = ProtoField.uint8("docan.data.byte_4", "Byte 4", base.HEX)
docan_data_byte_5 = ProtoField.uint8("docan.data.byte_5", "Byte 5", base.HEX)
docan_data_byte_6 = ProtoField.uint8("docan.data.byte_6", "Byte 6", base.HEX)
docan_data_byte_7 = ProtoField.uint8("docan.data.byte_7", "Byte 7", base.HEX)

docan_0x0a8_torque = ProtoField.float("docan.0x0a8.torque", "Torque (Nm)")
docan_0x0a8_torque_int = ProtoField.uint16("docan.0x0a8.torque_int", "Torque rounded (Nm)", base.DEC)

docan_0x0aa_throttle_position = ProtoField.uint16("docan.0x0aa.throttle_position", "Throttle position", base.DEC)
docan_0x0aa_rpm = ProtoField.int16("docan.0x0aa.rpm", "Engine RPM", base.DEC)

docan_0x130_byte_0 = ProtoField.uint8("docan.0x130.byte_0", "Byte 0", base.HEX, VALS_0X130_BYTE_0)
docan_0x130_byte_1 = ProtoField.uint8("docan.0x130.byte_1", "Byte 1", base.HEX)

-- create myproto protocol and its fields
-- local f_bitfield = ProtoField.uint8("myproto.bitfield", "Command", base.HEX, {[0]="Normal Packet", [1]="Last Packet"}, 0x40)

docan.fields = {
  docan_seatbelt_status, docan_canid,
  docan_data_byte_0, docan_data_byte_1, docan_data_byte_2, docan_data_byte_3,
  docan_data_byte_4, docan_data_byte_5, docan_data_byte_6, docan_data_byte_7,
  docan_0x0a8_torque, docan_0x0a8_torque_int,
  docan_0x0aa_throttle_position, docan_0x0aa_rpm,
  docan_0x130_byte_0, docan_0x130_byte_1
} 


docan_invalid = ProtoExpert.new("docan.invalid", "docan Invalid docan message", expert.group.SEQUENCE, expert.severity.WARN) 
docan.experts = {docan_invalid} 

-- register our postdissector
register_postdissector(docan)

-- format of entry: can_id, has_decode, decode_table, description, protofield_definition
canid_table = {
	{ 0x02fa, 0, 0, "Send frequency data", 0 },
	{ 0x0481, 1, subcmd_opmode_table, "Select transceive mode", civ_subcmd01 },
	{ 0x0581, 1, subcmd_opmode_table, "Seatbelt status", 0 },
	{ 0xff, 0, 0, "end of table", 0 }
}

-- This function gets called when a new trace file is loaded 
function docan.init() 
  if debug_set then print("Entering: docan.init()") end 
end 

function single_frame(buffer, ptr, tree)
  local info_text = ""
  local tvbr
  local byte_in_hex

  ptr = ptr + 1  -- skip the first byte

  info_text = "SingleFrame"

  return info_text
end

function first_frame(buffer, ptr, tree)
  local info_text = ""
  local tvbr
  local byte_in_hex

  info_text = "FirstFrame"

  return info_text
end

function consecutive_frame(buffer, ptr, tree)
  local info_text = ""
  local tvbr
  local byte_in_hex

  info_text = "ConsecutiveFrame"

  return info_text
end

function flow_control(buffer, ptr, tree)
  local info_text = ""
  local tvbr
  local byte_in_hex

  info_text = "FlowControl"

  return info_text
end


function docan.dissector(buffer,pinfo,tree) 

  local info_text 
  local ptr = 0
  local tvbr
  local info_text = "Unknown CAN ID"
  local i -- cmd_table index
  local j -- subcmd_table index

  local length = buffer:len()
  if length == 0 then return end

  can_length = docan_can_len_f().value
  can_id = docan_can_id_f().value

  if pinfo.visited then 

    if can_length > 0 then
		if can_id >= 0x600 and can_id < 0x700 then
			if debug_set then print("Processing DoCAN message") end
			pinfo.cols.protocol = docan.name

			vals = {}

			local subtree = tree:add(docan, buffer(), "ISO 15765 (DoCAN) Protocol")
			local rawdatatree = subtree:add(docan, buffer(), "DoCAN Raw Data")

			ptr = 24

			tvbr = buffer:range(ptr,1)  -- set up a range
			byte_in_hex = tvbr:uint()  -- extract the byte
			rawdatatree:add(docan_data_byte_0, byte_in_hex)
			ptr = ptr + 1

			tvbr = buffer:range(ptr,1)  -- set up a range
			byte_in_hex = tvbr:uint()  -- extract the byte
			rawdatatree:add(docan_data_byte_1, byte_in_hex)
			ptr = ptr + 1

			tvbr = buffer:range(ptr,1)  -- set up a range
			byte_in_hex = tvbr:uint()  -- extract the byte
			rawdatatree:add(docan_data_byte_2, byte_in_hex)
			ptr = ptr + 1

			tvbr = buffer:range(ptr,1)  -- set up a range
			byte_in_hex = tvbr:uint()  -- extract the byte
			rawdatatree:add(docan_data_byte_3, byte_in_hex)
			ptr = ptr + 1

			tvbr = buffer:range(ptr,1)  -- set up a range
			byte_in_hex = tvbr:uint()  -- extract the byte
			rawdatatree:add(docan_data_byte_4, byte_in_hex)
			ptr = ptr + 1

			tvbr = buffer:range(ptr,1)  -- set up a range
			byte_in_hex = tvbr:uint()  -- extract the byte
			rawdatatree:add(docan_data_byte_5, byte_in_hex)
			ptr = ptr + 1

			tvbr = buffer:range(ptr,1)  -- set up a range
			byte_in_hex = tvbr:uint()  -- extract the byte
			rawdatatree:add(docan_data_byte_6, byte_in_hex)
			ptr = ptr + 1

			tvbr = buffer:range(ptr,1)  -- set up a range
			byte_in_hex = tvbr:uint()  -- extract the byte
			rawdatatree:add(docan_data_byte_7, byte_in_hex)
			ptr = ptr + 1

			ptr = ptr - 8

			-- n_pcitype = docan_data_byte_1 and 0xf0
			n_pcitype = docan_data_byte_1 & 0xf0

			info_text = n_pcitype
			
			if n_pcitype == 0x00 then info_text = single_frame(buffer, ptr, subtree) end
			if n_pcitype == 0x10 then info_text = first_frame(buffer, ptr, subtree) end
			if n_pcitype == 0x20 then info_text = consecutive_frame(buffer, ptr, subtree) end
			if n_pcitype == 0x30 then info_text = flow_control(buffer, ptr, subtree) end
			
			pinfo.cols.info:set(info_text) 
			pinfo.cols.info:fence() 
		end
    end 

    if debug_set then print("SNAP03") end 
  end 
end 

