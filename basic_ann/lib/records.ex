require Record

defmodule Records do
  Record.defrecord(:sensor, [:id, :cx_id, :name, :vl, :fanout_ids])

  # Record.defrecord(:actuator, {:id, :cx_id, :name, :vl, :fanin_ids})
  # Record.defrecord(:neuron, {:id, :cx_id, :af, :input_idps, :output_ids})
  # Record.defrecord(:cortex, {:id, :sensor_ids, :actuator_ids, :nids})
end
