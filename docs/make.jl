using Documenter
using Example

import Documenter.Writers.HTMLWriter: render_navbar
using Documenter: Documents, Utilities
using Documenter.Utilities.DOM: DOM, Tag, @tags
using Documenter.Writers.HTMLWriter: pagetitle, mdconvert, navhref, getpage

function render_navbar(ctx, navnode, edit_page_link::Bool)
    @tags div header nav ul li a span

    # The breadcrumb (navigation links on top)
    navpath = Documents.navpath(navnode)
    header_links = map(navpath) do nn
        title = mdconvert(pagetitle(ctx, nn); droplinks=true)
        nn.page === nothing ? li(a[".is-disabled"](title)) : li(a[:href => navhref(ctx, nn, navnode)](title))
    end
    header_links[end] = header_links[end][".is-active"]
    breadcrumb = nav[".breadcrumb"](
        div["#site-map"](
            a[".site-map-entry", :href => "https://beta.turing.ml"]("Homepage"),
            a[".site-map-entry", :href => "https://beta.turing.ml"]("Get Started"),
            a[".site-map-entry", :href => "https://beta.turing.ml"]("Documentation"),
            a[".site-map-entry", :href => "https://beta.turing.ml"]("Tutorials"),
            a[".site-map-entry", :href => "https://beta.turing.ml"]("News"),
            a[".site-map-entry", :href => "https://beta.turing.ml"]("Team"),
        ),
        div(
            ul[".is-hidden-mobile"](header_links),
            ul[".is-hidden-tablet"](header_links[end]) # when on mobile, we only show the page title, basically
        )
    )

    # The "Edit on GitHub" links and the hamburger to open the sidebar (on mobile) float right
    navbar_right = div[".docs-right"]

    # Set the logo and name for the "Edit on.." button.
    if edit_page_link && (ctx.settings.edit_link !== nothing) && !ctx.settings.disable_git
        host_type = Utilities.repo_host_from_url(ctx.doc.user.repo)
        if host_type == Utilities.RepoGitlab
            host = "GitLab"
            logo = "\uf296"
        elseif host_type == Utilities.RepoGithub
            host = "GitHub"
            logo = "\uf09b"
        elseif host_type == Utilities.RepoBitbucket
            host = "BitBucket"
            logo = "\uf171"
        elseif host_type == Utilities.RepoAzureDevOps
            host = "Azure DevOps"
            logo = "\uf3ca" # TODO change to ADO logo when added to FontAwesome
        else
            host = ""
            logo = "\uf15c"
        end
        hoststring = isempty(host) ? " source" : " on $(host)"

        pageurl = get(getpage(ctx, navnode).globals.meta, :EditURL, getpage(ctx, navnode).source)
        edit_branch = isa(ctx.settings.edit_link, String) ? ctx.settings.edit_link : nothing
        url = if Utilities.isabsurl(pageurl)
            pageurl
        else
            if !(pageurl == getpage(ctx, navnode).source)
                # need to set users path relative the page itself
                pageurl = joinpath(first(splitdir(getpage(ctx, navnode).source)), pageurl)
            end
            Utilities.url(ctx.doc.user.repo, pageurl, commit=edit_branch)
        end
        if url !== nothing
            edit_verb = (edit_branch === nothing) ? "View" : "Edit"
            title = "$(edit_verb)$hoststring"
            push!(navbar_right.nodes,
                a[".docs-edit-link", :href => url, :title => title](
                    span[host_type == Utilities.RepoUnknown ? ".docs-icon.fa" : ".docs-icon.fab"](logo),
                    span[".docs-label.is-hidden-touch"](title)
                )
            )
        end
    end

    # Settings cog
    push!(navbar_right.nodes, a[
        "#documenter-settings-button.docs-settings-button.fas.fa-cog",
        :href => "#", :title => "Settings",
    ])

    # Hamburger on mobile
    push!(navbar_right.nodes, a[
        "#documenter-sidebar-button.docs-sidebar-button.fa.fa-bars.is-hidden-desktop",
        :href => "#"
    ])

    # Construct the main <header> node that should be the first element in div.docs-main
    header[".docs-navbar"](breadcrumb, navbar_right)
end

makedocs(
    sitename = "Example",
    format = Documenter.HTML(
        assets = ["assets/style.css"],
    ),
    modules = [Example],
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
