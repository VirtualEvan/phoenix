<template>
  <oc-table middle class="files-collaborators-collaborator">
    <oc-table-row
      v-if="$_reshareInformation"
      class="files-collaborators-collaborator-table-row-top"
    >
      <oc-table-cell shrink :colspan="firstColumn ? 2 : 1"></oc-table-cell>
      <oc-table-cell colspan="2">
        <div class="uk-text-meta">
          <oc-button
            :id="$_resharerToggleId"
            variation="raw"
            justify-content="left"
            gap-size="xsmall"
            :aria-label="$gettext('Show resharer details')"
            :uk-tooltip="$gettext('Show resharer details')"
          >
            <oc-icon name="repeat" size="small" class="uk-preserve-width" />
            <span
              class="oc-p-rm uk-text-truncate files-collaborators-collaborator-reshare-information"
              >{{ $_reshareInformation }}</span
            >
          </oc-button>
          <oc-drop
            ref="menu"
            :drop-id="$_resharerToggleId + '-drop'"
            :toggle="'#' + $_resharerToggleId"
            mode="click"
            :options="{ pos: 'bottom-left', delayHide: 0 }"
            class="uk-width-large oc-mt-s"
            close-on-click
          >
            <translate tag="h4">Shared by:</translate>
            <ul class="uk-list uk-list-divider uk-overflow-hidden oc-m-rm">
              <li v-for="resharer in collaborator.resharers" :key="resharer.name">
                <div class="uk-flex uk-flex-middle uk-flex-left">
                  <avatar-image
                    class="oc-mr-s"
                    :width="48"
                    :userid="resharer.name"
                    :user-name="resharer.displayName"
                  />
                  <div>
                    <span class="files-collaborators-resharer-name oc-text-bold">{{
                      resharer.displayName
                    }}</span>
                    <span
                      v-if="resharer.additionalInfo"
                      class="uk-text-meta files-collaborators-resharer-additional-info"
                      >({{ resharer.additionalInfo }})</span
                    >
                  </div>
                </div>
              </li>
            </ul>
          </oc-drop>
        </div>
      </oc-table-cell>
    </oc-table-row>
    <oc-table-row class="files-collaborators-collaborator-table-row-info">
      <oc-table-cell v-if="firstColumn" shrink>
        <oc-button
          v-if="$_deleteButtonVisible"
          :aria-label="$gettext('Delete share')"
          :uk-tooltip="$gettext('Delete share')"
          variation="raw"
          class="files-collaborators-collaborator-delete"
          @click="$_removeShare"
        >
          <oc-icon name="close" />
        </oc-button>
        <oc-spinner v-else-if="$_loadingSpinnerVisible" :aria-label="$gettext('Removing person')" />
        <oc-icon v-else name="lock" class="uk-invisible" />
      </oc-table-cell>
      <oc-table-cell shrink>
        <div key="collaborator-avatar-loaded">
          <avatar-image
            v-if="isUser"
            class="oc-mr-s files-collaborators-collaborator-indicator"
            :width="48"
            :userid="collaborator.collaborator.name"
            :user-name="collaborator.collaborator.displayName"
            :aria-label="$gettext('User')"
          />
          <div v-else key="collaborator-avatar-placeholder">
            <oc-icon
              v-if="collaborator.shareType === shareTypes.group"
              key="avatar-group"
              class="oc-mr-s files-collaborators-collaborator-indicator"
              name="group"
              size="xlarge"
              :aria-label="$gettext('Group')"
            />
            <oc-icon
              v-else
              key="avatar-generic-person"
              class="oc-mr-s files-collaborators-collaborator-indicator"
              name="person"
              size="xlarge"
              :aria-label="$gettext('Remote user')"
            />
          </div>
        </div>
      </oc-table-cell>
      <oc-table-cell>
        <div class="uk-flex uk-flex-column uk-flex-center" :class="collaboratorListItemClass">
          <div class="oc-text">
            <span>
              <span class="files-collaborators-collaborator-name oc-text-bold">{{
                collaborator.collaborator.displayName
              }}</span>
              <translate
                v-if="collaborator.collaborator.name === user.id"
                translate-comment="Indicator for current user in list of people"
                class="uk-text-meta files-collaborators-collaborator-additional-info"
              >
                (me)
              </translate>
            </span>
            <span
              v-if="collaborator.collaborator.additionalInfo"
              class="uk-text-meta files-collaborators-collaborator-additional-info"
              v-text="collaborator.collaborator.additionalInfo"
            />
          </div>
          <div
            v-if="collaborator.collaborator.name !== user.id"
            v-text="collaboratorType(collaborator.shareType)"
          />
          <span class="oc-text"
            ><span class="files-collaborators-collaborator-role">{{ originalRole.label }}</span
            ><template v-if="collaborator.expires">
              |
              <translate
                class="files-collaborators-collaborator-expires"
                :translate-params="{ expires: formDateFromNow(expirationDate) }"
                >Expires %{expires}</translate
              ></template
            ></span
          >
        </div>
      </oc-table-cell>
      <oc-table-cell shrink>
        <div class="uk-flex uk-flex-nowrap uk-flex-middle">
          <oc-button
            v-if="$_editButtonVisible"
            :aria-label="$gettext('Edit share')"
            :uk-tooltip="$gettext('Edit share')"
            variation="raw"
            class="files-collaborators-collaborator-edit"
            @click="$emit('onEdit', collaborator)"
          >
            <oc-icon name="edit" />
          </oc-button>
        </div>
      </oc-table-cell>
    </oc-table-row>
    <oc-table-row v-if="$_viaLabel" class="files-collaborators-collaborator-table-row-bottom">
      <oc-table-cell shrink :colspan="firstColumn ? 2 : 1"></oc-table-cell>
      <oc-table-cell colspan="2">
        <div class="uk-text-meta">
          <oc-button
            type="router-link"
            variation="raw"
            justify-content="left"
            gap-size="xsmall"
            :to="$_viaRouterParams"
            :aria-label="$gettext('Navigate to parent')"
            class="files-collaborators-collaborator-follow-via"
          >
            <oc-icon
              name="exit_to_app"
              class="uk-preserve-width"
              :uk-tooltip="$gettext('Navigate to parent')"
            />
            <span
              class="oc-file-name oc-p-rm uk-text-truncate files-collaborators-collaborator-via-label"
              >{{ $_viaLabel }}</span
            >
          </oc-button>
        </div>
      </oc-table-cell>
    </oc-table-row>
  </oc-table>
</template>

<script>
import { mapGetters } from 'vuex'
import moment from 'moment'
import { shareTypes } from '../../helpers/shareTypes'
import { basename, dirname } from 'path'
import CollaboratorsMixins from '../../mixins/collaborators'
import Mixins from '../../mixins'

export default {
  name: 'Collaborator',
  mixins: [Mixins, CollaboratorsMixins],
  props: {
    collaborator: {
      type: Object,
      required: true
    },
    modifiable: {
      type: Boolean,
      default: false
    },
    firstColumn: {
      type: Boolean,
      default: true
    }
  },
  data: function() {
    return {
      removalInProgress: false
    }
  },
  computed: {
    ...mapGetters(['user']),

    shareTypes() {
      return shareTypes
    },

    $_resharerToggleId() {
      return 'collaborator-' + this.collaborator.collaborator.name + '-resharer-details-toggle'
    },

    $_loadingSpinnerVisible() {
      return this.modifiable && this.removalInProgress
    },
    $_deleteButtonVisible() {
      return this.modifiable && !this.removalInProgress
    },
    $_editButtonVisible() {
      return this.modifiable && !this.removalInProgress
    },

    $_isIndirectShare() {
      // it is assumed that the "incoming" attribute only exists
      // on shares coming from this.collaborator.sTree which are all indirect
      // and not related to the current folder
      return this.collaborator.incoming || this.collaborator.outgoing
    },

    $_reshareInformation() {
      if (!this.collaborator.resharers) {
        return null
      }
      return this.collaborator.resharers.map(share => share.displayName).join(', ')
    },

    $_viaLabel() {
      if (!this.$_isIndirectShare) {
        return null
      }
      const translated = this.$gettext('Via %{folderName}')
      return this.$gettextInterpolate(
        translated,
        { folderName: basename(this.collaborator.path) },
        true
      )
    },

    $_viaRouterParams() {
      const viaPath = this.collaborator.path
      return {
        name: 'files-list',
        params: {
          item: dirname(viaPath) || '/'
        },
        query: {
          scrollTo: basename(viaPath)
        }
      }
    },

    originalRole() {
      if (this.collaborator.role.name === 'advancedRole') {
        return this.advancedRole
      }

      const role = this.displayRoles[this.collaborator.role.name]
      if (role) {
        return role
      }

      return {
        label: this.$gettext('Unknown Role')
      }
    },

    isUser() {
      return this.collaborator.shareType === this.shareTypes.user
    },

    isRemoteUser() {
      return this.collaborator.shareType === this.shareTypes.remote
    },

    collaboratorListItemClass() {
      const isUser = this.isUser || this.isRemoteUser

      return (
        'files-collaborators-collaborator-info-' +
        (isUser ? (this.isRemoteUser ? 'remote' : 'user') : 'group')
      )
    },

    expirationDate() {
      return moment(this.collaborator.expires).endOf('day')
    }
  },
  methods: {
    $_removeShare() {
      this.removalInProgress = true
      this.$emit('onDelete', this.collaborator)
    }
  }
}
</script>

<style scoped="scoped">
/* FIXME: Move to ODS somehow */
.files-collaborators-collaborator-table-row-top > td {
  padding: 0 10px 3px 0;
}
.files-collaborators-collaborator-table-row-info > td {
  padding: 0 10px 0 0;
}
.files-collaborators-collaborator-table-row-bottom > td {
  padding: 3px 10px 0 0;
}
.files-collaborators-collaborator-via-label {
  max-width: 75%;
}
</style>
<style>
/* TODO: Move to ODS  */
.oc-text {
  font-size: 1rem;
}
</style>
