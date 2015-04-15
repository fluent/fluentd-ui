## Release 0.3.21 - 2015/04/15

* [maintenance] [#187](https://github.com/fluent/fluentd-ui/pull/187) Remove needless gem
* [fixed] [#186](https://github.com/fluent/fluentd-ui/pull/186) Fix the bug when server restart while logged in and "Config File" page is visited
* [fixed] [#184](https://github.com/fluent/fluentd-ui/pull/184) Focus some inputboxes when its label is clicked
* [improve] [#180](https://github.com/fluent/fluentd-ui/pull/180) [#181](https://github.com/fluent/fluentd-ui/pull/181) [#183](https://github.com/fluent/fluentd-ui/pull/183) [#185](https://github.com/fluent/fluentd-ui/pull/185) Tweak design

## Release 0.3.20 - 2015/04/10

* [fixed] [#175](https://github.com/fluent/fluentd-ui/pull/175) Fix the bug password can be changed without match between new password and password confirmation.
* [fixed] [#177](https://github.com/fluent/fluentd-ui/pull/177) Use '0.0.0.0' as host not 'localhost' (If you want to change host, you can use `--host` option with `start` command)

## Release 0.3.19 - 2015/04/08

* [maintenance] [#170](https://github.com/fluent/fluentd-ui/pull/170) Update some gems
* [maintenance] [#171](https://github.com/fluent/fluentd-ui/pull/171) Update Rails to 4.2.1
* [maintenance] [#173](https://github.com/fluent/fluentd-ui/pull/173) Add Rake task to clean files under tmp/ directory (for packaging)

## Release 0.3.18 - 2015/04/02

* [fixed] [#167](https://github.com/fluent/fluentd-ui/pull/167) Apply bootstrap css to inputboxes in signin form
* [fixed] [#168](https://github.com/fluent/fluentd-ui/pull/168) Fix the behavor mismatch between configtest and update (update failed but configtest is OK)

## Release 0.3.17 - 2015/04/01

* [fixed] [#164](https://github.com/fluent/fluentd-ui/pull/164) Display add/remove icons correctly in out_forward settings page
* [fixed] [#165](https://github.com/fluent/fluentd-ui/pull/165) Fix zombie process is created by clicking start button in dashboard

## Release 0.3.16 - 2015/03/23

* [fixed] [#163](https://github.com/fluent/fluentd-ui/pull/163) Relax fluentd dependency

## Release 0.3.15 - 2015/03/11

* [fixed] [#159](https://github.com/fluent/fluentd-ui/pull/159) Fix latest out_s3 plugin compatibility
* [fixed] [#160](https://github.com/fluent/fluentd-ui/pull/160) Add validation that `buffer_path` required if `buffer_type` is file
* [maintenance] Minor refactors

## Release 0.3.14 - 2015/02/04

* [maintenance] [#150](https://github.com/fluent/fluentd-ui/pull/150), [#151](https://github.com/fluent/fluentd-ui/pull/151) minor fix in README.md.
* [maintenance] [#149](https://github.com/fluent/fluentd-ui/pull/149) Make circle-ci result stable.
* [maintenance] [#147](https://github.com/fluent/fluentd-ui/pull/147) Update gems.
* [maintenance] [#144](https://github.com/fluent/fluentd-ui/pull/144) Ignore useless bower files
* [fixed] [#146](https://github.com/fluent/fluentd-ui/pull/146) Fix to enable to too fast input in regex text box ([#145](https://github.com/fluent/fluentd-ui/pull/145) issue).
* [improve] [#152](https://github.com/fluent/fluentd-ui/pull/152) Add dry-run to config edit.
* [improve] [#153](https://github.com/fluent/fluentd-ui/pull/153) Show diff between current config and backup files.

## Release 0.3.13 - 2015/01/28

* [improve] [#143](https://github.com/fluent/fluentd-ui/pull/143) Use CodeMirror for setting edit

## Release 0.3.12 - 2015/01/16

* [maintenance] [#126](https://github.com/fluent/fluentd-ui/pull/126)-[#131](https://github.com/fluent/fluentd-ui/pull/131), [#135](https://github.com/fluent/fluentd-ui/pull/135), [#138](https://github.com/fluent/fluentd-ui/pull/138), [#139](https://github.com/fluent/fluentd-ui/pull/139) #CodeClimate score is now 4.0! special thanks to @rthbound for many pull-requests.
* [fixed] [#133](https://github.com/fluent/fluentd-ui/pull/133) Incompatible config generated on out_s3 version 0.5.x or newer.
* [fixed] [#140](https://github.com/fluent/fluentd-ui/pull/140) Fluentd::Agent#logged_errors methods returned wrong errors.
* [fixed] [#136](https://github.com/fluent/fluentd-ui/pull/136) Caused error on gem list fetching on some environments.
* [improve] [#124](https://github.com/fluent/fluentd-ui/pull/124) Enable to note config history.
* [improve] [#137](https://github.com/fluent/fluentd-ui/pull/137) Add "config test" button to config histories. You can check config before reuse that.

## Release 0.3.11 - 2014/12/19

* [improve] Save config history. Now any saved config files can be restored to the current.

## Release 0.3.10 - 2014/12/17

* [maintenance] Update components.
* [improve] Add fluentd default plugin settings.
* [fixed] Fix [#121](https://github.com/fluent/fluentd-ui/pull/121). Change to allow utf-8 string instead of ascii.

## Release 0.3.9 - 2014/12/01

* [improve] Display current setting for each section.
  https://github.com/fluent/fluentd-ui/pull/103
* [improve] Instantly current setting changing.
  https://github.com/fluent/fluentd-ui/pull/105
* [improve] Reduce polling access for notification fetching.

## Release 0.3.8 - 2014/11/19

* [improve] Recommended plugins are updated.
* [fixed] Plugin installation on td-agent-ui.

## Release 0.3.7 - 2014/11/13

* [maintenance] Change httpclient gem as stable version.

## Release 0.3.6 - 2014/11/12

* [improve] Don't install ri and rdoc.

## Release 0.3.5 - 2014/11/12

* [fixed] `/etc/init.d/td-agent stop` was killing the td-agent-ui on Debian based distributions.

## Release 0.3.4 - 2014/11/12

* yanked

## Release 0.3.3 - 2014/11/11

* [fixed] td-agent detection on Mac OS X

## Release 0.3.2 - 2014/11/10

* [fixed] Auto update fluentd-ui feature

## Release 0.3.1 - 2014/11/05

* [maintenance] Update dependencies
* [maintenance] Add dep:list rake task to help package td-agent

## Release 0.3.0 - 2014/10/22

* [feature] Potentially support for multiple user name (not have UI to do it)
* [improve] Improve installing plugin processing experience
* [improve] Some messages added or fixed

## Release 0.2.0 - 2014/09/02

* [compatibility] Login password is reset as default if v0.1.x user who updates thier password.
* [fixed] Keep changed password after update fluentd-ui gem.
* [fixed] Add missing LICENSE file (Apache license 2.0)
* [change] Remove bcrypt for packaging issue on Mac.

## Release 0.1.4 - 2014/08/20

* [fixed] Fix can't setting in_tail with format regexp.

## Release 0.1.3 - 2014/08/13

* [feature] Add out_elasticsearch setting

## Release 0.1.2 - 2014/08/07

* [fixed] Can't login if password changed from default

## Release 0.1.1 - 2014/08/07

* [fixed] Can't install a gem on some environment [#70](https://github.com/fluent/fluentd-ui/pull/70)
* [fixed] Can't setup in_tail if recognized as binary file selected [#71](https://github.com/fluent/fluentd-ui/pull/71)

## Release 0.1.0 - 2014/08/01

* First release!
