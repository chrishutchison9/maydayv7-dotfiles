export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    // Theme Switching
    const cookieHeader = request.headers.get("Cookie") || "";
    const cookies = Object.fromEntries(
      cookieHeader.split(";").map((c) => c.trim().split("="))
    );
    const themeCookie = cookies["theme_color"];
    if (url.pathname.endsWith("style.css")) {
      let theme = "red"; // Default
      if (themeCookie === "blue") theme = "blue";
      if (themeCookie === "black") theme = "black";
      if (theme !== "red") {
        const themeUrl = new URL(url);
        themeUrl.pathname = themeUrl.pathname.replace(
          "style.css",
          `style-${theme}.css`
        );
        let themeResponse = await env.ASSETS.fetch(
          new Request(themeUrl, request)
        );
        if (themeResponse.ok) {
          const newHeaders = new Headers(themeResponse.headers);
          newHeaders.set("Vary", "Cookie");
          newHeaders.set("Cache-Control", "private, max-age=60");
          return new Response(themeResponse.body, {
            ...themeResponse,
            headers: newHeaders,
          });
        }
      }
    }

    // Serve assets
    let response = await env.ASSETS.fetch(request);

    if (response.ok) {
      const newHeaders = new Headers(response.headers);
      newHeaders.set("Cache-Control", "public, max-age=60, s-maxage=60");
      return new Response(response.body, { ...response, headers: newHeaders });
    }

    return new Response("Repository not found.", { status: 404 });
  },
};
