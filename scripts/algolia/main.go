package main

import (
	"encoding/json"
	"log/slog"
	"os"
	"strings"

	"github.com/algolia/algoliasearch-client-go/v4/algolia/search"
)

type config struct {
	IndexName string               `json:"indexName"`
	Settings  search.IndexSettings `json:"settings"`
	Synonyms  [][]string           `json:"synonyms"`
}

func main() {
	if len(os.Args) != 2 {
		slog.Error("Usage: go run . <path-to-config.json>")
		os.Exit(1)
	}
	configPath := os.Args[1]

	appID := os.Getenv("ALGOLIA_APP_ID")
	apiKey := os.Getenv("ALGOLIA_API_KEY")
	if appID == "" || apiKey == "" {
		slog.Error("ALGOLIA_APP_ID and ALGOLIA_API_KEY must be set")
		os.Exit(1)
	}

	data, err := os.ReadFile(configPath)
	if err != nil {
		slog.Error("Failed to read config file", "path", configPath, "error", err)
		os.Exit(1)
	}

	var cfg config
	if err := json.Unmarshal(data, &cfg); err != nil {
		slog.Error("Failed to parse config file", "path", configPath, "error", err)
		os.Exit(1)
	}

	if cfg.IndexName == "" {
		slog.Error("indexName is required in config file", "path", configPath)
		os.Exit(1)
	}

	client, err := search.NewClient(appID, apiKey)
	if err != nil {
		slog.Error("Failed to create Algolia client", "error", err)
		os.Exit(1)
	}

	slog.Info("Updating index settings", "index", cfg.IndexName)
	settingsResp, err := client.SetSettings(client.NewApiSetSettingsRequest(cfg.IndexName, &cfg.Settings))
	if err != nil {
		slog.Error("Failed to set index settings", "index", cfg.IndexName, "error", err)
		os.Exit(1)
	}
	slog.Info("Index settings updated", "index", cfg.IndexName, "taskID", settingsResp.TaskID, "updatedAt", settingsResp.UpdatedAt)

	if len(cfg.Synonyms) > 0 {
		synonymHits := make([]search.SynonymHit, len(cfg.Synonyms))
		for i, words := range cfg.Synonyms {
			id := strings.ToLower(strings.ReplaceAll(words[0], " ", "-"))
			synonymHits[i] = *search.NewEmptySynonymHit().
				SetObjectID(id).
				SetType(search.SYNONYM_TYPE_SYNONYM).
				SetSynonyms(words)
		}

		slog.Info("Updating synonyms", "index", cfg.IndexName, "count", len(synonymHits))
		synonymsResp, err := client.SaveSynonyms(
			client.NewApiSaveSynonymsRequest(cfg.IndexName, synonymHits).
				WithReplaceExistingSynonyms(true),
		)
		if err != nil {
			slog.Error("Failed to save synonyms", "index", cfg.IndexName, "error", err)
			os.Exit(1)
		}
		slog.Info("Synonyms updated", "index", cfg.IndexName, "taskID", synonymsResp.TaskID, "updatedAt", synonymsResp.UpdatedAt)
	}
}
