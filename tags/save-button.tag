<save-button>
  <button type="submit" class="btn btn-primary"
          disabled="{ opts.saving || !opts.valid }">
    <span if="{ !opts.saving }"><yield/></span>
    <span if="{ opts.saving }">
      <i class="fa fa-refresh fa-spin"></i> Saving...
    </span>
  </button>
</save-button>
