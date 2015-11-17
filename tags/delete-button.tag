<delete-button>
  <button class="btn btn-danger"
          disabled="{ opts.working }"
          onclick="{ opts.onclick }"">
    <span if="{ !opts.working }"><yield/></span>
    <span if="{ opts.working }">
      <i class="fa fa-refresh fa-spin"></i> Deleting...
    </span>
  </button>
</delete-button>
