# Comment installer Buildkite Agent

L'agent Buildkite s'exécute sur votre propre machine, qu'il s'agisse d'un VPS, d'un serveur, d'un ordinateur de bureau, d'un périphérique intégré. Il existe des installateurs pour :

<% AGENT_INSTALLERS.each do |installer|%>
*   [<%= installer [:title.] %>] (<%= docs_page_path installer.[:url.] %>) <% end%>

Vous pouvez également l'installer manuellement en utilisant les instructions ci-dessous.

## Installation manuelle.

Si vous devez installer l'agent sur un système non répertorié ci-dessus, vous devrez effectuer une installation manuelle à l'aide de l'un des binaires de...  [Page de sortie de Buildkite-Agent.](https://github.com/buildkite/agent/releases).


   Une fois que vous avez un binaire, créez. 'bin' et 'builds' directories in   ' and copy the binary and   


" 'bash.
mkdir ~/.buildkite-agent ~/.buildkite-agent/bin ~/.buildkite-agent/builds
cp buildkite-agent ~/.buildkite-agent/bin
cp bootstrap.sh ~/.buildkite-agent/bootstrap.sh
"'

You should now be able to start the agent:

"'bash.
buildkite-agent start --help
"'

Si votre architecture n'est pas sur la page des versions, envoyez un e-mail à l'assistance et nous vous aiderons, ou consultez le... [Buildkite-agent's Readme.](https://github.com/buildkite/agent#readme) pour des instructions sur la façon de le compiler vous-même.

## Upgrade agents

To update your agents, you can either:

* Use the package manager for your operating system.
* Re-run the installation script.

As long as you're using Agent v3 or later, no configuration changes are necessary.
