svgs =
  Enum.map(
    SVGMTest.Helpers.list_svgs(:assets) ++ SVGMTest.Helpers.list_svgs(:svgm_core),
    &SVGMTest.Helpers.read_svg!/1
  )

Benchee.run(
  %{
    "SVGM.optimize!(svgs) when length(svgs) == #{length(svgs)}" => fn ->
      Enum.each(svgs, &SVGM.optimize!/1)
    end
  },
  time: 5
)
