defmodule SimplestNn do
  @moduledoc """
  Documentation for SimplestNn.
  This source code and work is provided and developed by DXNN Research Group WWW.DXNNResearch.COM
  Copyright (C) 2012 by Gene Sher, DXNN Research Group, CorticalComputer@gmail.com
  All rights reserved.

  This code is licensed under the version 3 of the GNU General Public License. Please see the LICENSE file that accompanies this project for the terms of use.
  Code ported to Elixir by Daniel Benjaminsson.
  """

  @doc """
  The create function first generates 3 weights, with the 3rd weight being the Bias.
  The Neuron is spawned first, and is then sent the PIds of the Sensor and Actuator
  that it's connected with. Then the Cortex element is registered and provided with
  the PIds of all the elements in the NN system.
  """
  def create() do
    weights = [:rand.uniform() - 0.5, :rand.uniform() - 0.5, :rand.uniform() - 0.5]
    n_pid = spawn(__MODULE__, :neuron, [weights, :undefined, :undefined])
    s_pid = spawn(__MODULE__, :sensor, [n_pid])
    a_pid = spawn(__MODULE__, :actuator, [n_pid])
    send(n_pid, {:init, s_pid, a_pid})
    Process.register(spawn(__MODULE__, :cortex, [s_pid, n_pid, a_pid]), :cortex)
  end

  @doc """
  After the neuron finishes setting its SPId and APId to that of the Sensor and Actuator
  respectively, it starts waiting for the incoming signals. The neuron expects a vector
  of length 2 as input, and as soon as the input arrives, the neuron processes the signal
  and passes the output vector to the outgoing APId.
  """
  def neuron(weights, _s_pid, a_pid) do
    receive do
      {s_pid, :forward, inputs} ->
        :io.format("****Thinking****~n Input:~p~n with Weights:~p~n", [inputs, weights])
        dot_p = dot_product(inputs, weights, 0)
        output = [:math.tanh(dot_p)]
        send(a_pid, {self(), :forward, output})
        neuron(weights, s_pid, a_pid)

      {:init, new_spid, new_apid} ->
        neuron(weights, new_spid, new_apid)

      :terminate ->
        :ok
    end
  end

  # If needed, more info at: https://en.wikipedia.org/wiki/Dot_product
  def dot_product([i | inputs], [w | weights], acc) do
    dot_product(inputs, weights, i * w + acc)
  end

  def dot_product([], [bias], acc), do: acc + bias

  @doc """
  The Sensor function waits to be triggered by the Cortex element, and then produces a
  random vector of length 2, which it passes to the connected neuron. In a proper system the
  sensory signal would not be a random vector but instead would be produced by a function
  associated with the sensor, a function that for example reads and vector-encodes a signal
  coming from a GPS attached to a robot.
  """
  def sensor(n_pid) do
    receive do
      :sync ->
        sensor_signal = [:rand.uniform(), :rand.uniform()]
        :io.format("****Sensing****~n Signal from the environment :~p~n", [sensor_signal])
        send(n_pid, {self(), :forward, sensor_signal})
        sensor(n_pid)

      :terminate ->
        :ok
    end
  end

  @doc """
  The Actuator function waits for a control signal coming from a Neuron.
  As soon as the signal arrives, the actuator executes its function, pts/1,
  which prints the value to the screen.
  """
  def actuator(_n_pid) do
    receive do
      {n_pid, :forward, control_signal} ->
        pts(control_signal)
        actuator(n_pid)

      :terminate ->
        :ok
    end
  end

  def pts(control_signal) do
    :io.format("****Acting****~n Using:~p to act on environment.~n", [control_signal])
  end

  @doc """
  The Cortex function triggers the sensor to action when commanded by the user.
  This process also has all the PIds of the elements in the NN system, so that it can
  terminate the whole system when requested.
  """
  def cortex(sensor_pid, neuron_pid, actuator_pid) do
    receive do
      :sense_think_act ->
        send(sensor_pid, :sync)
        cortex(sensor_pid, neuron_pid, actuator_pid)

      :terminate ->
        send(sensor_pid, :terminate)
        send(neuron_pid, :terminate)
        send(actuator_pid, :terminate)
        :ok
    end
  end
end
