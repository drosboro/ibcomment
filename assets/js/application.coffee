# @codekit-prepend "../../bower_components/jquery/dist/jquery.js"
# @codekit-prepend "../../bower_components/bootstrap/dist/js/bootstrap.js"
# @codekit-prepend "../../bower_components/handlebars/handlebars.js"
# @codekit-prepend "../../bower_components/Countable/Countable.js"
# @codekit-prepend "dp_grade_descriptors.js"

courseList = ["Group 1", "Group 2 SL", "Group 3", "Group 4", "Group 5", "Group 6", "EE", "TOK"]

convertToSlug = (t) ->
  t.toLowerCase().replace(RegExp(' ', 'g'), '-').replace /[^\w-]+/g, ''

grade_panel_str = (g) ->
  Handlebars.registerPartial('statementTemplate', $('#statement-template').html())
  panel_html = $('#grade-panel-template').html().replace("{{&gt;", "  {{>")
  panel_templ = Handlebars.compile(panel_html)

  slug = convertToSlug(g["grade"])

  s_dict = g["statements"].map (e) -> {s: e}
  context = { panelID: slug, grade: g["grade"], statements: s_dict }

  return panel_templ(context)


build_tab = (i) ->
  return if courseList.indexOf(i["subject"]) == -1
  tab_tpl = Handlebars.compile($('#tab-template').html())
  pane_tpl = Handlebars.compile($('#pane-template').html())

  tab_str = tab_tpl({ link: convertToSlug(i["subject"]), subject: i["subject"] })

  levels = ""
  x = 0
  while x < i["levels"].length
    levels += grade_panel_str(i["levels"][x])
    x++

  pane_str = pane_tpl({ slug: convertToSlug(i["subject"]), paneContent: levels})

  $('ul#course-tabs').append(tab_str)
  $('#content-tab').append(pane_str)

$ ->
  gd.map build_tab

  $('#course-tabs a:first').tab('show')

  $('#course-tabs a').click (e) ->
    e.preventDefault()
    $(this).tab 'show'
    return

  $('li.statement').click (e) ->
    e.preventDefault()
    $(this).toggleClass("selected")
    updateComment()
    focusForClipboard()

  $('input#student-name').on 'input', ->
    updateComment()

  $('#clear-btn').click (e) ->
    e.preventDefault()
    $("li.statement").removeClass("selected")
    $("input#student-name").val("")
    updateComment()

  focusForClipboard = ->
    $("#comment-content").select()

  updateComment = ->
    selected = $("li.selected").get()
    clauses = []
    clauses.push $.trim(c.innerHTML) for c in selected

    str = $("input#student-name").val()
    str += " " if str.length > 0
    str += clauses.join("; ")
    str += "." if clauses.length > 0
    str = str.charAt(0).toUpperCase() + str.slice(1)

    console.log(str)

    ccta = $("textarea#comment-content")
    ccta.val(str)
    ccta.height(54)
    ccta.height(Math.min(ccta[0].scrollHeight-10, $(window).height()-220))

    cc = $("#comment-content").get(0)
  
    Countable.once cc, (counter) ->
      $("#wc").html(counter.words)


  p = $("#comment-panel")
  pos = p.position()

  $(window).scroll (e) ->
    windowPos = $(window).scrollTop()
    if windowPos >= pos.top
      p.addClass("stick");
    else
      p.removeClass("stick");

  $("#student-name").focus()



