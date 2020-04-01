Docs::Application.config.session_store :cookie_store, key: '_bk_docs_sess',
                                                      expire_after: 1.year,
                                                      secure: Rails.env.production?

