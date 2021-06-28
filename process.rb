f = open(ARGV[0])
measures = f.read.split("\n")
f.close

values = {}
measures.each do |measure|
  fields = measure.split(",")
  fields.slice(1..).each_with_index do |sensor, i|
    i+=1

    if values[i].nil?
      values[i] = 0
    end
  
    ship, sensor_value = sensor.gsub("(","").gsub(")","").split("|")
    if sensor_value.to_i >= 100
      values[i] += 1
    elsif sensor_value.to_i <= 0
      values[i] -= 1
    else
      values[i] = 0
    end

    if values[i] >= 30
      puts "{\"type\":\"Nave enemiga acercandose\", \"when\": \"#{fields[0]}\", \"sensor\": #{i}, \"tipo\":\"#{ship}\"}"
      values[i] = 0
    elsif values[i] <= -32
      puts "{\"type\":\"sensor averiado\", \"when\": \"#{fields[0]}\", \"sensor\": #{i}}"
      values[i] = 0
    end
  end
end


=begin
casos de prueba

probar un sensor sin alarmas
probar un sensor con 1 alarma de nave y una alarma de falla
probar un sensor con 2 alarmas de nave y dos alarmas de falla
probar un sensor con 3 alarmas de vave y tres de falla
=end
