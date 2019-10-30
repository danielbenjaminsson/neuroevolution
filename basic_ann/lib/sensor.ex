defmodule Sensor do
  require Records

  def gen(exoself_pid, node) do
    spawn(node, __MODULE__, :loop, [exoself_pid])
  end

  def loop(_exoself_pid) do
    receive do
      {_exoself_pid, {id, cx_pid, sensor_name, vl, fanout_pids}} ->
        loop(id, cx_pid, sensor_name, vl, fanout_pids)
    end
  end

  def loop(id, _cx_pid, sensor_name, vl, fanout_pids) do
    receive do
      {cx_pid, :sync} ->
        sensory_vector = :sensor.sensor_name(vl)
        send(cx_pid, {self(), :forward, sensory_vector} || cx_pid <- fanout_pids)
        loop(id, cx_pid, sensor_name, vl, fanout_pids)

      {_cx_pid, :terminate} ->
        :ok
    end
  end

  def rng(vl) do
    rng(vl, [])
  end

  def rng(0, acc) do
    acc
  end

  def rng(vl, acc) do
    rng(vl - 1, [:rand.uniform() | acc])
  end
end
