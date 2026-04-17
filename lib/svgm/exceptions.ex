defmodule SVGM.Exceptions do
  @moduledoc false

  defmodule XMLParseError do
    @moduledoc """
    An exception raised when the SVG is invalid XML.
    """
    defexception [:message]
  end

  defmodule UnexpectedEOFError do
    @moduledoc """
    An exception raised when encountering an unexpected end of file.
    """
    defexception [:message]
  end

  defmodule MismatchedTagError do
    @moduledoc """
    An exception raised when a tag is mismatched.

    Typically when a closing tag does not match an opening tag.
    """
    defexception [:message, :expected, :found]
  end
end
