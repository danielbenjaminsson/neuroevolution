defmodule Constructor do
  @moduledoc """
  Documentation for Constructor.
  This source code and work is provided and developed by DXNN Research Group WWW.DXNNResearch.COM
  Copyright (C) 2012 by Gene Sher, DXNN Research Group, CorticalComputer@gmail.com
  All rights reserved.

  This code is licensed under the version 3 of the GNU General Public License. Please see the LICENSE file that accompanies this project for the terms of use.
  Code ported to Elixir by Daniel Benjaminsson.
  """

  @doc """
  The construct_genotype function accepts the name of the file to which we'll save the genotype,
  sensor name, actuator name, and the hidden layer density parameters.
  We have to generate unique Ids for every sensor and actuator. The sensor and actuator names are
  used as input to the create_Sensor and create_Actuator functions, which in turn generate the
  actual Sensor and Actuator representing tuples.

  We create unique Ids for sensors and actuators so that when in the future a NN uses 2 or more
  sensors or actuators of the same type, we will be able to differentiate between them using
  their Ids. After the Sensor and Actuator tuples are generated, we extract the NN's input and
  output vector lengths from the sensor and actuator used by the system.

  The Input_VL is then used to specify how many weights the neurons in the input layer will need,
  and the Output_VL specifies how many neurons are in the output layer of the NN.

  After appending the HiddenLayerDensites to the now known number of neurons in the last layer
  to generate the full LayerDensities list, we use the create_NeuroLayers function to generate
  the Neuron representing tuples. We then update the Sensor and Actuator records with proper fanin
  and fanout ids from the freshly created Neuron tuples, composes the Cortex, and write the genotype
  to file.
  """
  def construct_genotype(sensor_name, actuator_name, hidden_layer_densities) do
    construct_genotype(:ffnn, sensor_name, actuator_name, hidden_layer_densities)
  end

  def construct_genotype(file_name, sensor_name, actuator_name, hidden_layer_densities) do
    s = create_sensor(sensor_name)
    a = create_actuator(actuator_name)
    #   output_vl = a#actuator.vl
    layer_densities = Enum.into(hidden_layer_densities, [output_vl])
    cx_id = {:cortex, generate_id()}

    neurons = create_neuro_layers(cx_id, s, a, layer_densities)
    [input_layer | _] = neurons
    [output_layer | _] = Enum.reverse(neurons)
    #    fl_nids = [n#{neuron.id} || n <- input_layer]
    #    ll_nids = [n#{neuron.id} || n <- output_layer]
    #    nids = [n#neuron.id || n <- List.flatten(nerurons)]
    #    sensor = s#sensor{cx_id = cx_id fanout_ids = fl_nids}
    #    actuator = a#actuator{cx_id = cx_id fanout_ids = ll_nids}
    #    cortex = create_cortex(cx_id, [s#sensor.id], [a#actuator.id], nids)
    genotype = List.flatten([cortex, sensor, actuator | neurons])
    {:ok, file} = File.open!(filename, :write)
    Enum.each(genotype, fn x -> IO.puts("#{x}\n") end)
    File.close(file)
    genotype
  end

  @doc """
  Every sensor and actuator uses some kind of function associated with it.
  A function that either polls the environment for sensory signals (in the case of a sensor) or
  acts upon the environment (in the case of an actuator). It is a function that we need to define
  and program before it is used, and the name of the function is the same as the name of the sensor
  or actuator it self. For example, the create_Sensor/1 has specified only the rng sensor,
  because that is the only sensor function we've finished developing.

  The rng function has its own vector length specification, which will determine the number of weights that
  a neuron will need to allocate if it is to accept this sensor's output vector. The same principles
  apply to the create_Actuator function. Both, create_Sensor and create_Actuator function, given
  the name of the sensor or actuator, will return a record with all the specifications of that element,
  each with its own unique Id.
  """
  def create_sensor(sensor_name) do
    case sensor_name do
      :rng ->
        # sensor{id={:sensor, generate_id(),}, name = rng, vector_length=2}
        :nop

      _ ->
        IO.puts("System does not yet support a sensor by the name #{sensor_name}.")
        exit(:normal)
    end
  end

  def create_actuator(actuator_name) do
    case actuator_name do
      :pts ->
        # actuator{id={:actuator, generate_id(),}, name = pts, vector_length=1}
        :nop

      _ ->
        IO.puts("System does not yet support an actuator by the name. #{actuator_name}")
        exit(:normal)
    end
  end

  @doc """
  The function create_NeuroLayers/3 prepares the initial step before starting the recursive
  create_NeuroLayers/7 function which will create all the Neuron records. We first generate
  the place holder Input Ids “plus”(Input_IdPs), which are tuples composed of Ids and the vector
  lengths of the incoming signals associated with them.
  The proper input_idps will have a weight list in the tuple instead of the vector length.
  Because we are only building NNs each with only a single Sensor and Actuator, the IdP to the
  first layer is composed of the single Sensor Id with the vector length of its sensory signal,
  likewise in the case of the Actuator.
  We then generate unique ids for the neurons in the first layer, and drop into the recursive
  create_NeuroLayers/7 function.
  """
  def create_neuro_layers(cx_id, sensor, actuator, layer_densities) do
    # input_idps = [{sensor#sensor.id, sensor#sensor.vector_length}]
    tot_layers = length(layer_densities)
    [fl_neurons | next_lds] = layer_densities
    nids = [{:neuron, {1, id}} || id <- generate_ids(fl_neurons, [])]

    # create_neuro_layers(cx_id, actuator#actuator.id, 1, tot_layers, input_idps, nids, next_lds, [])
  end

  @doc """
  During the first iteration, the first layer neuron ids constructed in create_NeuroLayers/3 are held
  in the NIds variable. In create_NeuroLayers/7, with every iteration we generate the Output_NIds,
  which are the Ids of the neurons in the next layer. The last layer is a special case which occurs
  when LayerIndex == Tot_Layers. Having the Input_IdPs, and the Output_NIds, we are able to construct
  a neuron record for every Id in NIds using the function create_layer/4. The Ids of the constructed
  Output_NIds will become the NIds variable of the next iteration, and the Ids of the neurons in the
  current layer will be extended and become Next_InputIdPs. We then drop into the next iteration with
  the newly prepared Next_InputIdPs and Output_NIds. Finally, when we reach the last layer,
  the Output_Ids is the list containing a single Id of the Actuator element.
  We use the same function, create_NeuroLayer/4, to construct the last layer and return the result.
  """

  def create_neuro_layers(
        cx_id,
        actuator_id,
        layer_index,
        tot_layers,
        input_idps,
        nids,
        [next_ld | lds],
        acc
      ) do
    output_nids = [{:neuron, {layer_index + 1, id}} || id <- generate_ids(next_ld, [])]
    layer_neurons = create_neurolayer(cx_id, input_idps, nids, output_nids, [])
    next_input_idps = [{nid, 1} || nid <- nids]

    create_neuro_layers(
      cx_id,
      actuator_id,
      layer_index + 1,
      tot_layers,
      next_input_idps,
      output_nids,
      lds,
      [layer_neurons | acc]
    )
  end

  @doc """
  To create neurons from the same layer, all that is needed are the Ids for those neurons, a list of
  Input_IdPs for every neuron so that we can create the proper number of weights, and a list of Output_Ids.
  Since in our simple feed forward neural network all neurons are fully connected to the neurons in the
  next layer, the Input_IdPs and Output_Ids are the same for every neuron belonging to the same layer.
  """
  def create_neuro_layers(cx_id, actuator_id, tot_layers, tot_layers, input_idps, nids, [], acc) do
    output_ids = [actuator_id]
    layer_neurons = create_neuro_layer(cx_id, input_idps, nids, output_ids, [])
    Enum.reverse([layer_neurons | acc])
  end

  @doc """
  Each neuron record is composed by the create_Neuron/3 function. The create_Neuron/3 function
  creates the Input list from the tuples [{Id,Weights}...] using the vector lengths specified
  in the place holder Input_IdPs. The create_NeuralInput/2 function uses create_NeuralWeights/2
  to generate the random weights in the range of -0.5 to 0.5, adding the bias to the end of
  the list.
  """
  def create_neuron(input_idps, id, cx_id, output_ids) do
    proper_input_idps = create_neural_input(input_idps, [])

    # :neuron{id=id, cx_id = cx_id, af = tanh, input_idps = proper_input_idps, output_ids = output_ids}

    def create_neural_input([{input_id, input_vl} | input_idps], acc) do
      weights = create_neural_weights(input_vl, [])
      create_neural_input(input_idps, [{input_id, weights} | acc])
    end

    def create_neural_input([], acc) do
      Enum.reverse([{:bias, :rand.uniform() - 0.5} | acc])

      def create_neural_weights(0, acc) do
        acc
      end

      def create_neural_weights(index, acc) do
        w = :rand.uniform() - 0.5
        create_neural_weights(index - 1, [w | acc])
      end
    end

    def generate_ids(0, acc) do
      acc
    end

    def generate_ids(index, acc) do
      id = generate_id()
      generate_ids(index - 1, [id | acc])
    end

    @doc """
    The generate_id/0 creates a unique Id using current time, the Id is a floating point value.
    The generate_ids/2 function creates a list of unique Ids.
    """
    def generate_id() do
      {mega_seconds, seconds, micro_seconds} = :os.timestamp()
      1 / (mega_seconds * 1_000_000 + seconds + micro_seconds / 1_000_000)
    end
  end

  @doc """
  The create_Cortex/4 function generates the record encoded genotypical representation of
  the cortex element. The Cortex element needs to know the Id of every Neuron, Sensors,
  and Actuator in the NN.
  """
  def create_cortex(cx_id, s_ids, a_ids, n_ids) do
    # cortex{id = cx_id, sensor_ids = s_ids, actuator_ids = a_ids, nids = nids}
  end
end
