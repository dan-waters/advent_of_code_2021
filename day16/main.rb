class Packet
  attr_accessor :version, :type, :sub_packets

  def initialize(version, type, value, sub_packets)
    @version = version
    @type = type
    @value = value
    @sub_packets = sub_packets
  end

  def self.parse(value)
    version = value.shift(3).join.to_i(2)
    type = value.shift(3).join.to_i(2)
    
    if type == 4
      lit_val = ''
      loop do
        slice = value.shift(5)
        lit_val += slice[1..4].join
        break if slice[0] == '0'
      end
      lit_val = lit_val.to_i(2)
      Packet.new(version, type, lit_val, [])
    else
      indicator = value.shift
      sub_packets = []
      if indicator == '0'
        length = value.shift(15).join.to_i(2)
        expected_end = value.length - length
        until value.length <= expected_end
          sub_packets << parse(value)
        end
      elsif indicator == '1'
        count = value.shift(11).join.to_i(2)
        until sub_packets.count == count
          sub_packets << parse(value)
        end
      end

      Packet.new(version, type, nil, sub_packets)
    end
  end

  def version_sum
    version + sub_packets.map(&:version_sum).sum
  end

  def value
    case type
    when 0
      sub_packets.map(&:value).sum
    when 1
      sub_packets.map(&:value).inject(:*)
    when 2
      sub_packets.map(&:value).min
    when 3
      sub_packets.map(&:value).max
    when 4
      @value
    when 5
      sub_packets[0].value > sub_packets[1].value ? 1 : 0
    when 6
      sub_packets[0].value < sub_packets[1].value ? 1 : 0
    when 7
      sub_packets[0].value == sub_packets[1].value ? 1 : 0
    end
  end
end

HEX_MAP = {
  '0' => '0000',
  '1' => '0001',
  '2' => '0010',
  '3' => '0011',
  '4' => '0100',
  '5' => '0101',
  '6' => '0110',
  '7' => '0111',
  '8' => '1000',
  '9' => '1001',
  'A' => '1010',
  'B' => '1011',
  'C' => '1100',
  'D' => '1101',
  'E' => '1110',
  'F' => '1111'
}

def hex_to_bin(hex)
  hex.chars.map do |char|
    HEX_MAP[char]
  end.join.chars
end

packet = Packet.parse(hex_to_bin('420D50000B318100415919B24E72D6509AE67F87195A3CCC518CC01197D538C3E00BC9A349A09802D258CC16FC016100660DC4283200087C6485F1C8C015A00A5A5FB19C363F2FD8CE1B1B99DE81D00C9D3002100B58002AB5400D50038008DA2020A9C00F300248065A4016B4C00810028003D9600CA4C0084007B8400A0002AA6F68440274080331D20C4300004323CC32830200D42A85D1BE4F1C1440072E4630F2CCD624206008CC5B3E3AB00580010E8710862F0803D06E10C65000946442A631EC2EC30926A600D2A583653BE2D98BFE3820975787C600A680252AC9354FFE8CD23BE1E180253548D057002429794BD4759794BD4709AEDAFF0530043003511006E24C4685A00087C428811EE7FD8BBC1805D28C73C93262526CB36AC600DCB9649334A23900AA9257963FEF17D8028200DC608A71B80010A8D50C23E9802B37AA40EA801CD96EDA25B39593BB002A33F72D9AD959802525BCD6D36CC00D580010A86D1761F080311AE32C73500224E3BCD6D0AE5600024F92F654E5F6132B49979802129DC6593401591389CA62A4840101C9064A34499E4A1B180276008CDEFA0D37BE834F6F11B13900923E008CF6611BC65BCB2CB46B3A779D4C998A848DED30F0014288010A8451062B980311C21BC7C20042A2846782A400834916CFA5B8013374F6A33973C532F071000B565F47F15A526273BB129B6D9985680680111C728FD339BDBD8F03980230A6C0119774999A09001093E34600A60052B2B1D7EF60C958EBF7B074D7AF4928CD6BA5A40208E002F935E855AE68EE56F3ED271E6B44460084AB55002572F3289B78600A6647D1E5F6871BE5E598099006512207600BCDCBCFD23CE463678100467680D27BAE920804119DBFA96E05F00431269D255DDA528D83A577285B91BCCB4802AB95A5C9B001299793FCD24C5D600BC652523D82D3FCB56EF737F045008E0FCDC7DAE40B64F7F799F3981F2490'))

puts packet.version_sum, packet.value