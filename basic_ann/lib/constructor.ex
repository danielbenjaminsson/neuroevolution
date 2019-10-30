defmodule Constructor do
  require Records

  def construct_genotype(sensor_name, actuator_name, hidden_layer_densitities) do
    construct_genotype(:ffnn, sensor_name, actuator_name, hidden_layer_densitities)
  end

  def construct_genotype(file_name, sensor_name, actuator_name, hidden_layer_densities) do
    s = create_sensor(sensor_name)
    a = create_actuator(actuator_name)
    output_vl = Record.Extractor.extract(Records, :sensor)
  end
end
