defmodule Muster.Game.Tile do
  @type id :: pos_integer()
  @type index :: pos_integer()
  @type value :: pos_integer()

  @type t :: %__MODULE__{
          id: id(),
          row: index(),
          column: index(),
          value: value()
        }

  @enforce_keys ~w(row column value)a
  defstruct ~w(id row column value)a

  @spec reverse_column(t(), max_column :: index()) :: t()
  def reverse_column(%__MODULE__{} = tile, max_column) do
    %__MODULE__{tile | column: max_column - tile.column}
  end

  @spec transpose(t()) :: t()
  def transpose(%__MODULE__{} = tile) do
    %__MODULE__{tile | row: tile.column, column: tile.row}
  end

  @spec compare(t(), t()) :: :lt | :eq | :gt
  def compare(%__MODULE__{} = tile1, %__MODULE__{} = tile2) do
    case {{tile1.row, tile1.column}, {tile2.row, tile2.column}} do
      {first, second} when first > second -> :gt
      {first, second} when first < second -> :lt
      _ -> :eq
    end
  end
end
