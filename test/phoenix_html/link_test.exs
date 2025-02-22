defmodule Phoenix.HTML.LinkTest do
  use ExUnit.Case, async: true

  import Phoenix.HTML
  import Phoenix.HTML.Link

  test "link with post" do
    csrf_token = Plug.CSRFProtection.get_csrf_token()

    assert safe_to_string(link("hello", to: "/world", method: :post)) ==
             ~s[<a data-csrf="#{csrf_token}" data-method="post" data-to="/world" href="/world" rel="nofollow">hello</a>]
  end

  test "link with %URI{}" do
    url = "https://elixir-lang.org/"

    assert safe_to_string(link("elixir", to: url)) ==
             safe_to_string(link("elixir", to: URI.parse(url)))

    path = "/elixir"

    assert safe_to_string(link("elixir", to: path)) ==
             safe_to_string(link("elixir", to: URI.parse(path)))
  end

  test "link with put/delete" do
    csrf_token = Plug.CSRFProtection.get_csrf_token()

    assert safe_to_string(link("hello", to: "/world", method: :put)) ==
             ~s[<a data-csrf="#{csrf_token}" data-method="put" data-to="/world" href="/world" rel="nofollow">hello</a>]
  end

  test "link with put/delete without csrf_token" do
    assert safe_to_string(link("hello", to: "/world", method: :put, csrf_token: false)) ==
             ~s[<a data-method="put" data-to="/world" href="/world" rel="nofollow">hello</a>]
  end

  test "link with :do contents" do
    assert ~s[<a href="/hello"><p>world</p></a>] ==
             safe_to_string(
               link to: "/hello" do
                 Phoenix.HTML.Tag.content_tag(:p, "world")
               end
             )

    assert safe_to_string(
             link(to: "/hello") do
               "world"
             end
           ) == ~s[<a href="/hello">world</a>]
  end

  test "link with scheme" do
    assert safe_to_string(link("foo", to: "/javascript:alert(<1>)")) ==
             ~s[<a href="/javascript:alert(&lt;1&gt;)">foo</a>]

    assert safe_to_string(link("foo", to: {:safe, "/javascript:alert(<1>)"})) ==
             ~s[<a href="/javascript:alert(<1>)">foo</a>]

    assert safe_to_string(link("foo", to: {:javascript, "alert(<1>)"})) ==
             ~s[<a href="javascript:alert(&lt;1&gt;)">foo</a>]

    assert safe_to_string(link("foo", to: {:javascript, 'alert(<1>)'})) ==
             ~s[<a href="javascript:alert(&lt;1&gt;)">foo</a>]

    assert safe_to_string(link("foo", to: {:javascript, {:safe, "alert(<1>)"}})) ==
             ~s[<a href="javascript:alert(<1>)">foo</a>]

    assert safe_to_string(link("foo", to: {:javascript, {:safe, 'alert(<1>)'}})) ==
             ~s[<a href="javascript:alert(<1>)">foo</a>]
  end

  test "link with invalid args" do
    msg = "expected non-nil value for :to in link/2"

    assert_raise ArgumentError, msg, fn ->
      link("foo", bar: "baz")
    end

    msg = "link/2 requires a keyword list as second argument"

    assert_raise ArgumentError, msg, fn ->
      link("foo", "/login")
    end

    assert_raise ArgumentError, ~r"unsupported scheme given as link", fn ->
      link("foo", to: "javascript:alert(1)")
    end

    assert_raise ArgumentError, ~r"unsupported scheme given as link", fn ->
      link("foo", to: {:safe, "javascript:alert(1)"})
    end

    assert_raise ArgumentError, ~r"unsupported scheme given as link", fn ->
      link("foo", to: {:safe, 'javascript:alert(1)'})
    end
  end

  test "button with post (default)" do
    csrf_token = Plug.CSRFProtection.get_csrf_token()

    assert safe_to_string(button("hello", to: "/world")) ==
             ~s[<button data-csrf="#{csrf_token}" data-method="post" data-to="/world">hello</button>]
  end

  test "button with %URI{}" do
    url = "https://elixir-lang.org/"

    assert safe_to_string(button("elixir", to: url, csrf_token: false)) ==
             safe_to_string(button("elixir", to: URI.parse(url), csrf_token: false))
  end

  test "button with post without csrf_token" do
    assert safe_to_string(button("hello", to: "/world", csrf_token: false)) ==
             ~s[<button data-method="post" data-to="/world">hello</button>]
  end

  test "button with get does not generate CSRF" do
    assert safe_to_string(button("hello", to: "/world", method: :get)) ==
             ~s[<button data-method="get" data-to="/world">hello</button>]
  end

  test "button with do" do
    csrf_token = Plug.CSRFProtection.get_csrf_token()

    output =
      safe_to_string(
        button to: "/world", class: "small" do
          raw("<span>Hi</span>")
        end
      )

    assert output ==
             ~s[<button class="small" data-csrf="#{csrf_token}" data-method="post" data-to="/world"><span>Hi</span></button>]
  end

  test "button with class overrides default" do
    csrf_token = Plug.CSRFProtection.get_csrf_token()

    assert safe_to_string(button("hello", to: "/world", class: "btn rounded", id: "btn")) ==
             ~s[<button class="btn rounded" data-csrf="#{csrf_token}" data-method="post" data-to="/world" id="btn">hello</button>]
  end

  test "button with invalid args" do
    assert_raise ArgumentError, ~r/unsupported scheme given as link/, fn ->
      button("foo", to: "javascript:alert(1)", method: :get)
    end
  end
end
