import { Controller } from "@hotwired/stimulus";
export default class extends Controller {
  connect() {
    $(function () {
      $(document).on("click", "#reset-filters", function (e) {
        let ele = $(this).closest(".top-action").find(".input-blank__filter");
        ele.each((index, element) => {
          $(element).val("");
        });
      });
    });
    $("#start_date").on("keydown", function (e) {
      e.preventDefault();
    });
    $("#start_date").on("keydown", function (e) {
      e.preventDefault();
    });

    $(document).on('click', '.download-logs', function (e) {
      const url = $(this).data("url");
      const promptId = $(this).data("prompt");
      const keyword = $('#log-keyword').val();
      const startDate = $('#start_date').val();
      const endDate = $('#end_date').val();
      window.location.href = `${url}?prompt_id=${promptId}&keyword=${keyword}&start_date=${startDate}&end_date=${endDate}`;
    });
  }
}
