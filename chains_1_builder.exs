defmodule Chain do
  def counter(next_pid) do
    receive do
      n ->
        send next_pid, n + 1
    end
    # note the recursive call here
    counter(next_pid)
  end

  def create_process(send_to) do
    last = spawn(Chain, :counter, [send_to])
    send last, 0

    receive do
      final_answer when is_integer(final_answer) ->
        {last, "Result for #{inspect self()} is #{inspect(final_answer)}"}
    end
  end

  def build_chain(n, parent) do
    Enum.reduce 1..n, self(),
      fn(_, send_to) -> 
        {last, msg} = create_process(send_to)
        send parent, msg
        last
    end
  end

  def receive_outputs() do
    receive do
      msg when is_bitstring(msg) ->
        IO.puts inspect msg
    end
    receive_outputs()
  end

  def run(n) do
    Enum.each 1..8, 
      fn(_) ->
        spawn(Chain, :build_chain, [n, self()])
      end

    receive_outputs()
  end
end

Chain.run(1_000_000)
