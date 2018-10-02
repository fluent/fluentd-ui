"user strict";

const state = {
  type: null,
  expression: null,
  timeFormat: null,
  messageFormat: null,
  rfc5424TimeFormat: null,
  withPriority: null,
};

const getters = {
  toParams: (state) => {
    return {
      expression: state.expression,
      time_format: state.timeFormat,
      message_format: state.messageFormat,
      rfc5424_time_format: state.rfc5424TimeFormat,
      with_priority: state.withPriority
    };
  },
  pluginName: (state) => {
    return state.type;
  }
};

const actions = {
  updateType({ commit, state }, event) {
    commit("setType", event.target.value);
    commit("clearParams");
  },
  updateExpression({ commit, state }, event) {
    commit("setExpression", event.target.value);
  },
  updateTimeFormat({ commit, state }, event) {
    commit("setTimeFormat", event.target.value);
  },
  updateMessageFormat({ commit, state }, event) {
    commit("setMessageFormat", event.target.value);
  },
  updateRfc5424TimeFormat({ commit, state }, event) {
    commit("setRfc5424TimeFormat", event.target.value);
  },
  updateWithPriority({ commit, state }, event) {
    commit("setWithPriority", event.target.value);
  }
};

const mutations = {
  setType(state, value) {
    state.type = value;
  },
  setExpression(state, value) {
    state.expression = value;
  },
  setTimeFormat(state, value) {
    state.timeFormat = value;
  },
  setMessageFormat(state, value) {
    state.messageFormat = value;
  },
  setRfc5424TimeFormat(state, value) {
    state.rfc5424TimeFormat = value;
  },
  setWithPriority(state, value) {
    state.withPriority = value;
  },
  clearParams(state) {
    state.expression = null;
    state.timeFormat = null;
    state.messageFormat = null;
    state.rfc5424TimeFormat = null;
    state.withPriority = null;
  }
};

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations
};
