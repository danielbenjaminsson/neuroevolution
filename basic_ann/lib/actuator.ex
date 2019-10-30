defmodule Actuator do
  require Records

  def gen(exoself_pid, node) do
    spawn(node, __MODULE__, :prep, [exoself_pid])
  end

  def prep(exoself_pid, node) do
    receive do
      {exoself_pid, {id, cx_pid, scape, actuator_name, fanin_pids}} ->
        loop(id, exoself_pid, cx_pid, scape, actuator_name, {fanin_pids, fanin_pids}, [])
    end
  end

  def loop(id, exoself_pid, cx_pid, scane, aname, {[from_pid, fanin_pids], mfanin_pids}, acc) do
    receive do
      {from_pid, :forward, input} ->
        loop(id, exoself_pid, cx_pid, scane, aname, {fanin_pids, mfanin_pids}, input ++ acc)

      {from_pid, :terminate} ->
        :ok
    end
  end

  def loop(id, exoself_pid, cx_pid, scape, aname, {[], mfanin_pids}, acc) do
    {fitness, end_flag} = Actuator.aname(Enum.reverse(acc), scape)
    send(cx_pid, {self(), :sync, fitness, end_flag})
    loop(id, exoself_pid, cx_pid, scape, aname, {mfanin_pids, mfanin_pids}, [])
  end

  def pts(result(_scape)) do
    :io.format("actuator:pts(result): ~p~n, [Result]")
    {1, 0}
  end

  def xor_send_output(output, scape) do
    send(scape, {self(), :action, output})

    receive do
      {scape, fitness, halt_flag} ->
        {fitness, halt_flag}
    end
  end
end
