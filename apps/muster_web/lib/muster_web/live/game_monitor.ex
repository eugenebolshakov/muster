defmodule MusterWeb.GameMonitor do
  use GenServer

  @impl true
  def init(processes) do
    {:ok, processes}
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, %{}, opts)
  end

  def monitor(callback) do
    GenServer.call(__MODULE__, {:monitor, callback})
  end

  def demonitor() do
    GenServer.call(__MODULE__, :demonitor)
  end

  @impl true
  def handle_call({:monitor, callback}, {pid, _ref}, processes) do
    ref = Process.monitor(pid)
    {:reply, :ok, Map.put(processes, pid, %{ref: ref, callback: callback})}
  end

  @impl true
  def handle_call(:demonitor, {pid, _ref}, processes) do
    {process, processes} = Map.pop(processes, pid)
    if process do
      Process.demonitor(process.ref)
    end
    {:reply, :ok, processes}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _reason}, processes) do
    {process, processes} = Map.pop(processes, pid)
    Task.start(fn -> process.callback.() end)
    {:noreply, processes}
  end
end
