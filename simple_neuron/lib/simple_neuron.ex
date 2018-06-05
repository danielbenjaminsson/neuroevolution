defmodule SimpleNeuron do
  @moduledoc """
  Documentation for SimpleNeuron.
  """

  @doc """
  The create function spawns a single neuron, where the weights
  and the bias are generated randomly to be between -0.5 and 0.5.
  """
  def create() do
    weights = [:rand.uniform() - 0.5, :rand.uniform() - 0.5, :rand.uniform() - 0.5]
    Process.register(spawn(__MODULE__, :loop, [weights]), :neuron)
  end

  def loop(weights) do
    receive do
      {from_pid, inputs} ->
        :io.format("****Processing****~nInput:~p~nUsing Weights:~p~n", [inputs, weights])
        output = dot_product(inputs, weights, 0) |> :math.tanh()
        send(from_pid, {:result, [output]})
        loop(weights)
    end
  end

  # If needed, more info: https://en.wikipedia.org/wiki/Dot_product
  def dot_product([i | inputs], [w | weights], acc) do
    dot_product(inputs, weights, i * w + acc)
  end

  def dot_product([], [bias], acc), do: acc + bias

  @doc """
  Sense function expects a vector of 2 elements as input
  and feed this as input to the single neuron.
  """
  def sense(signal) do
    case is_list(signal) and length(signal) == 2 do
      true ->
        send(:neuron, {self(), signal})

        receive do
          {:result, output} ->
            :io.format("Output: ~p~n", [output])
        end

      false ->
        msg = "The signal must a list of length 2.~n"
        :io.format(msg)
        {:error, msg}
    end
  end
end
