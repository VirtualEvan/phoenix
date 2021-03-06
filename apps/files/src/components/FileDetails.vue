<template>
  <oc-app-side-bar
    id="files-sidebar"
    :key="highlightedFile.id"
    class="oc-p-s uk-overflow-auto uk-height-1-1 oc-border-l"
    :disable-action="false"
    @close="close()"
  >
    <template v-if="highlightedFile" slot="title">
      <div class="uk-inline">
        <oc-icon :name="fileTypeIcon(highlightedFile)" size="xlarge" />
      </div>
      <div class="uk-inline">
        <div class="uk-flex uk-flex-middle">
          <span
            id="files-sidebar-item-name"
            class="oc-mr-s oc-text-bold"
            v-text="highlightedFile.name"
          />
        </div>
        <div v-if="$route.name !== 'files-shared-with-others'" class="uk-flex uk-flex-middle">
          <oc-star
            v-if="!publicPage() && isFavoritesEnabled"
            id="files-sidebar-star-icon"
            class="uk-inline oc-mr-xs"
            :shining="highlightedFile.starred"
            @click.native.stop="toggleFileFavorite(highlightedFile)"
          />
          <template v-if="highlightedFile.size > -1">
            {{ highlightedFile.size | fileSize }},
          </template>
          {{ formDateFromNow(highlightedFile.mdate) }}
        </div>
      </div>
    </template>
    <template slot="content">
      <oc-accordion class="oc-mt-m" :expand-first="true" :expanded-id="expandedAccordionId">
        <oc-accordion-item
          v-for="accordion in fileSideBarsEnabled"
          :id="buildAppSidebarId(accordion.app)"
          :key="accordion.app"
          :title="accordion.component.title($gettext)"
          :icon="accordion.icon"
        >
          <component :is="accordion.component" />
        </oc-accordion-item>
      </oc-accordion>
    </template>
  </oc-app-side-bar>
</template>

<script>
import Mixins from '../mixins'
import { mapActions, mapGetters, mapState, mapMutations } from 'vuex'

export default {
  name: 'FileDetails',
  mixins: [Mixins],
  computed: {
    ...mapGetters(['getToken', 'fileSideBars', 'capabilities']),
    ...mapGetters('Files', ['highlightedFile']),
    ...mapState('Files', ['appSidebarExpandedAccordion']),

    fileSideBarsEnabled() {
      return this.fileSideBars.filter(
        b => b.enabled === undefined || b.enabled(this.capabilities, this.highlightedFile)
      )
    },

    isFavoritesEnabled() {
      return this.capabilities.files && this.capabilities.files.favorites
    },

    expandedAccordionId() {
      return this.buildAppSidebarId(this.appSidebarExpandedAccordion)
    }
  },

  beforeDestroy() {
    this.SET_APP_SIDEBAR_EXPANDED_ACCORDION(null)
  },

  methods: {
    ...mapActions('Files', ['deleteFiles', 'markFavorite']),
    ...mapActions(['showMessage']),
    ...mapMutations('Files', ['SET_APP_SIDEBAR_EXPANDED_ACCORDION']),

    close() {
      this.$emit('reset')
    },

    toggleFileFavorite(file) {
      this.markFavorite({
        client: this.$client,
        file: file
      })
    },

    buildAppSidebarId(accordion) {
      if (accordion) {
        return `app-sidebar-${accordion}`
      }
      return null
    }
  }
}
</script>
