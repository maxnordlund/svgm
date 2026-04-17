# SVGM binding for Elixir
<!-- Start SVGM module doc -->
NIF wrapper for [svgm-core][], a SVG optimization library in Rust.

There's also a CLI and nodejs package, see https://svgm.dev/ for more info.

[svgm-core]: https://crates.io/crates/svgm-core

<!-- End SVGM module doc -->

## Installation

The package can be installed by adding `svgm` to your list of dependencies in
`mix.exs`:

```elixir
def deps do
  [
    {:svgm, "~> 0.3.7"}
  ]
end
```

Or with [`Mix.install/1`][]:

```elixir
Mix.install([:svgm])
```

## Usage
<!-- Start SVGM.optimize!/2 doc -->
Returns an optimized version of the given SVG.

This also accepts a couple of `t:options/0`, see the [Rust documentation][1]
for details.

### Examples
The examples comes from the [SVG tutorial on Mozilla Developer Network][2],
and [svgm-core's test suite][3].

![SVG tutorial example](assets/tutorial_logo.svg)

The most basic usage is to just supply the SVG to be optimized.

```elixir
iex> svg = ~s|
...> <svg version="1.1"
...>     width="300" height="200"
...>     xmlns="http://www.w3.org/2000/svg">
...>   <rect width="100%" height="100%" fill="red" />
...>   <circle cx="150" cy="100" r="80" fill="green" />
...>   <text x="150" y="125" font-size="60" text-anchor="middle" fill="white">SVG</text>
...> </svg>|
iex> SVGM.optimize!(svg)
~s|<svg xmlns="http://www.w3.org/2000/svg" height="200" width="300"><rect fill="red" height="100%" width="100%"/><circle cx="150" cy="100" fill="green" r="80"/><text fill="#fff" font-size="60" text-anchor="middle" x="150" y="125">SVG</text></svg>|
```

You may also provide options to tweak the process a bit, see the [Rust
documentation][1] for details.

```elixir
iex> svg = ~s|
...> <svg version="1.1"
...>     width="300" height="200"
...>     xmlns="http://www.w3.org/2000/svg">
...>   <rect width="100%" height="100%" fill="red" />
...>   <circle cx="150" cy="100" r="80" fill="green" />
...>   <text x="150" y="125" font-size="60" text-anchor="middle" fill="white">SVG</text>
...> </svg>|
iex> SVGM.optimize!(svg, preset: :safe, precision: 1, pass_overrides: %{
...>   "convertColors" => false
...> })
~s|<svg xmlns="http://www.w3.org/2000/svg" height="200" width="300"><rect fill="red" height="100%" width="100%"/><circle cx="150" cy="100" fill="green" r="80"/><text fill="white" font-size="60" text-anchor="middle" x="150" y="125">SVG</text></svg>|
```

Note how the color of the `<text>` stays `"white"`, unlike above where it has
been shortened to `"#fff"`.

It raises an error when given invalid SVG.

```elixir
iex> SVGM.optimize!("<svg></svg")
** (SVGM.Exceptions.XMLParseError) XML parse error ...
```
```elixir
iex> SVGM.optimize!("<svg></b></svg>")
** (SVGM.Exceptions.MismatchedTagError) mismatched closing tag: ...
```

The same goes for invalid options.

```elixir
iex> SVGM.optimize!("<svg></svg>", preset: :foo)
** (ArgumentError) Erlang error: "Could not decode field :preset on %Options{}"
```
```elixir
iex> SVGM.optimize!("<svg></svg>", precision: 1.5)
** (ArgumentError) Erlang error: "Could not decode field :precision on %Options{}"
```
```elixir
iex> SVGM.optimize!("<svg></svg>", pass_overrides: %{must_be_string_keys: false})
** (ArgumentError) Erlang error: "Could not decode field :pass_overrides on %Options{}"
```
```elixir
iex> SVGM.optimize!("<svg></svg>", pass_overrides: %{"convertColors" => nil})
** (ArgumentError) Erlang error: "Could not decode field :pass_overrides on %Options{}"
```

[1]: https://docs.rs/svgm-core/latest/svgm_core/config/struct.Config.html
[2]: https://developer.mozilla.org/en-US/docs/Web/SVG/Tutorials/SVG_from_scratch/Getting_started
[3]: https://github.com/madebyfrmwrk/svgm/tree/main/crates/svgm-core/tests/fixtures

<!-- End SVGM.optimize!/2 doc -->

## Forcing compilation

By default **you don't need Rust installed** because the lib will try to
download a precompiled NIF file. In case you want to force compilation set the
`SVGM_BUILD` environment variable to `true` or `1`. Alternatively you can also
set the application env `:build_from_source` to `true` in order to force the
build:

```elixir
config :svgm, Svgm, build_from_source: true
```

You also need to add Rustler to your dependencies when you want to force the
compilation:

```elixir
def deps do
  [
    {:svgm, "~> 0.3.7"},
    {:rustler, ">= 0.37.3", optional: true}
  ]
end
```

## Copyright and License

Licensed under either of

- Apache License, Version 2.0, ([LICENSE-APACHE](../LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
- MIT license ([LICENSE-MIT](../LICENSE-MIT) or http://opensource.org/licenses/MIT)

at your option.

## Contribution

Unless you explicitly state otherwise, any contribution intentionally submitted
for inclusion in the work by you, as defined in the Apache-2.0 license, shall be
dual licensed as above, without any additional terms or conditions.

[`Mix.install/1`]: https://hexdocs.pm/mix/Mix.html#install/2
