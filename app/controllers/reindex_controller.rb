class ReindexController < ApplicationController
  def reindex
    ModelIndexer.run

    render plain: "Последний реиндекс: #{Time.now}"
  end
end
