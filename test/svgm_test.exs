defmodule SVGMTest do
  import SVGMTest.Helpers

  use ExUnit.Case, async: true

  doctest SVGM

  describe "SVGM.optimize!/2" do
    test "basic usage" do
      assert SVGM.optimize!(read_svg!("assets/tutorial_logo.svg")) ==
               ~s|<svg xmlns="http://www.w3.org/2000/svg" height="200" width="300"><rect fill="red" height="100%" width="100%"/><circle cx="150" cy="100" fill="green" r="80"/><text fill="#fff" font-size="60" text-anchor="middle" x="150" y="125">SVG</text></svg>|

      assert SVGM.optimize!(read_svg!("assets/preserves_animation.svg")) ==
               ~s|<svg xmlns="http://www.w3.org/2000/svg" height="100" width="100"><path d="M0 0h100v100H0z" fill="red"><animate attributeName="opacity" dur="2s" from="1" repeatCount="indefinite" to="0"/></path><circle cx="50" cy="50" fill="blue" r="20"><animateTransform attributeName="transform" dur="3s" from="0 50 50" repeatCount="indefinite" to="360 50 50" type="rotate"/></circle></svg>|
    end

    test "with options" do
      assert SVGM.optimize!(read_svg!("assets/preserves_animation.svg"),
               preset: :safe,
               precision: 1,
               pass_overrides: %{
                 "convertColors" => false
               }
             ) ==
               ~s|<svg xmlns="http://www.w3.org/2000/svg" height="100" width="100"><rect fill="red" height="100" width="100"><animate attributeName="opacity" dur="2s" from="1" repeatCount="indefinite" to="0"/></rect><circle cx="50" cy="50" fill="blue" r="20"><animateTransform attributeName="transform" dur="3s" from="0 50 50" repeatCount="indefinite" to="360 50 50" type="rotate"/></circle></svg>|
    end
  end

  for source <- ~w(assets svgm_core)a do
    describe "#{source} fixtures" do
      for svg_fixture <- list_svgs(source) do
        test svg_fixture do
          svg = read_svg!(unquote(svg_fixture))
          assert String.length(SVGM.optimize!(svg)) <= String.length(svg)
        end
      end
    end
  end
end
